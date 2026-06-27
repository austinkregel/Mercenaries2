"""Resolve internal Lua 5.1 C API function RVAs by disassembling the thin
Lua-base-library wrappers we already located via find_lua_print.py.

Uses Capstone (x86, 32-bit) so we get correct instruction boundaries — the
previous one-byte-lookahead walker mistook operand bytes for opcodes.

For each wrapper, we walk linearly from its entry point, collecting every
`call rel32` until we hit `ret` / `ret imm16` / a long stretch of `int3`
padding. Then we cross-reference targets against what the wrapper is known
to call (from the public Lua 5.1.2 source).

Wrappers and what they should call (lbaselib.c):
    luaB_print:      lua_gettop, lua_getfield (via getglobal macro),
                     lua_pushvalue x2, lua_call, lua_tolstring,
                     lua_settop (via pop macro), plus CRT fputs
    luaB_pcall:      luaL_checkany, lua_pcall, lua_pushboolean, lua_insert
    luaB_xpcall:     luaL_checkany, lua_settop(L,2), lua_insert, lua_pcall,
                     lua_pushboolean, lua_replace
    luaB_tostring:   luaL_checkany, lua_getmetatable, lua_call (if __tostring),
                     lua_tolstring
    luaB_loadstring: luaL_checklstring, luaL_optlstring (= luaL_optstring
                     when arg is string), luaL_loadbuffer, load_aux

Run:
    py tools/resolve_lua_api.py "C:\\Games\\Mercenaries 2 World in Flames\\Mercenaries2.exe.bak"
"""

from __future__ import annotations

import struct
import sys
from collections import Counter, OrderedDict
from dataclasses import dataclass
from pathlib import Path
from typing import Optional

from capstone import Cs, CS_ARCH_X86, CS_MODE_32, CsInsn  # type: ignore

sys.path.insert(0, str(Path(__file__).resolve().parent))
from find_lua_print import PE, Section  # noqa: E402


# Wrapper RVAs from the Lua base-library array (find_lua_print output).
WRAPPERS: OrderedDict[str, int] = OrderedDict([
    ("luaB_print",      0x002aef90),
    ("luaB_pcall",      0x00461810),
    ("luaB_xpcall",     0x004618e0),
    ("luaB_loadstring", 0x004611e0),
    ("luaB_tostring",   0x00461a10),
    ("luaB_unpack",     0x00461630),  # has explicit lua_settop
    ("luaB_select",     0x00461740),  # has lua_gettop in source
    ("luaB_assert",     0x00461570),  # has lua_gettop as last call (return lua_gettop(L))
    ("luaB_error",      0x004606a0),  # has explicit lua_settop(L,1), lua_concat, lua_error
    ("luaB_tonumber",   0x004604c0),  # has explicit lua_tonumber via luaL_optnumber
    ("luaB_rawequal",   0x00460b20),  # has lua_rawequal + 2x luaL_checkany
    ("luaB_rawget",     0x00460bd0),  # has lua_rawget + checktype
    ("luaB_rawset",     0x00460c90),  # has lua_rawset + checktype
    ("luaB_next",       0x00460f00),  # has lua_settop(L,2) + lua_next
    ("luaB_type",       0x00460e90),  # has luaL_checkany + lua_typename + lua_pushstring
])


@dataclass
class Wrapper:
    name: str
    rva: int
    raw: bytes
    calls: list[tuple[int, int]]   # (call_site_va, target_va)
    other_jumps: list[tuple[int, int]]
    stop_reason: str
    insn_count: int


def slice_function(pe: PE, rva: int, max_bytes: int = 2048) -> tuple[bytes, int]:
    """Pull `max_bytes` of raw bytes starting at `rva`. Returns (bytes, vaddr)."""
    sec = pe.section_for_va(pe.image_base + rva)
    if sec is None:
        return b"", 0
    off = (rva - sec.virtual_address)
    end = min(off + max_bytes, len(sec.data))
    return sec.data[off:end], pe.image_base + sec.virtual_address + off


def disasm_wrapper(pe: PE, md: Cs, name: str, rva: int) -> Wrapper:
    raw, base_va = slice_function(pe, rva, max_bytes=2048)
    calls: list[tuple[int, int]] = []
    other_jumps: list[tuple[int, int]] = []
    stop_reason = "max_bytes"
    int3_run = 0
    insn_count = 0

    for insn in md.disasm(raw, base_va):
        insn_count += 1
        mnem = insn.mnemonic
        # padding: a run of int3 (compiler inter-function fill) means we
        # walked past the function end.
        if mnem == "int3":
            int3_run += 1
            if int3_run >= 3:
                stop_reason = "int3-padding"
                break
            continue
        int3_run = 0

        # NOTE: we do NOT stop on `ret` anymore — many helper wrappers have
        # multiple ret instructions (early-out branches) and we'd miss calls
        # past the first one. We rely on the 0xCC padding to mark the real
        # function end. This means we may absorb a few calls from a
        # sibling function if there's no padding; cross-wrapper consensus
        # filters those out.
        if mnem == "call":
            op = insn.op_str
            # direct call: op_str is the absolute target as hex
            try:
                target = int(op, 16)
                calls.append((insn.address, target))
            except ValueError:
                # indirect call (call dword ptr [...] / call eax) — skip
                pass
        elif mnem == "jmp":
            op = insn.op_str
            try:
                target = int(op, 16)
                other_jumps.append((insn.address, target))
                # An unconditional jmp typically ends a function too, but only
                # if it's a tail call out of the function body. We let the
                # loop run a few more bytes to catch padding behind it.
            except ValueError:
                pass

    return Wrapper(
        name=name,
        rva=rva,
        raw=raw[: insn_count and (md_last_offset(raw, md, base_va, insn_count))],
        calls=calls,
        other_jumps=other_jumps,
        stop_reason=stop_reason,
        insn_count=insn_count,
    )


def md_last_offset(raw: bytes, md: Cs, base_va: int, n: int) -> int:
    """Compute the offset within `raw` corresponding to the end of the n-th
    instruction. Cheap and only used for display."""
    off = 0
    for i, insn in enumerate(md.disasm(raw, base_va)):
        off = insn.address - base_va + insn.size
        if i + 1 >= n:
            break
    return off


def label_target(pe: PE, va: int) -> str:
    sec = pe.section_for_va(va)
    if sec is None:
        return "??"
    return f"in {sec.name}"


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    path = Path(sys.argv[1])
    pe = PE.parse(path)
    md = Cs(CS_ARCH_X86, CS_MODE_32)
    md.detail = False

    print(f"loaded {path}, image_base=0x{pe.image_base:08x}\n")

    wrappers: list[Wrapper] = []
    all_targets: Counter[int] = Counter()

    for name, rva in WRAPPERS.items():
        w = disasm_wrapper(pe, md, name, rva)
        wrappers.append(w)
        for _, t in w.calls:
            all_targets[t] += 1
        print(f"=== {name} @ RVA 0x{rva:08x}   "
              f"({w.insn_count} insns, stopped on {w.stop_reason})")
        # Print each call with a tiny window of disasm around it.
        for site_va, t_va in w.calls:
            t_rva = t_va - pe.image_base
            print(f"    call @ 0x{site_va:08x}  -> 0x{t_va:08x}  "
                  f"(RVA 0x{t_rva:08x}, {label_target(pe, t_va)})")
        for site_va, t_va in w.other_jumps:
            t_rva = t_va - pe.image_base
            print(f"    jmp  @ 0x{site_va:08x}  -> 0x{t_va:08x}  "
                  f"(RVA 0x{t_rva:08x}, {label_target(pe, t_va)})")
        print()

    print("=== shared call targets (called from 2+ wrappers) ===")
    for t_va, count in sorted(all_targets.items(), key=lambda kv: -kv[1]):
        if count < 2:
            continue
        t_rva = t_va - pe.image_base
        callers = [w.name for w in wrappers if any(tv == t_va for _, tv in w.calls)]
        print(f"  0x{t_va:08x}  (RVA 0x{t_rva:08x})  x{count}   "
              f"called by: {', '.join(callers)}")

    # Dump the first 64 bytes of luaB_print so we can see if it's a trampoline.
    print("\n=== luaB_print raw bytes (first 64) ===")
    raw, base_va = slice_function(pe, WRAPPERS["luaB_print"], max_bytes=64)
    hexes = " ".join(f"{b:02x}" for b in raw)
    print(f"  {hexes}")
    print(f"  -- disassembly:")
    for insn in md.disasm(raw, base_va):
        if insn.address - base_va >= 48:
            break
        print(f"  {insn.address:08x}  {insn.bytes.hex():<14}  "
              f"{insn.mnemonic} {insn.op_str}")

    print("\n=== identification cheat-sheet (Lua 5.1.2 source) ===")
    print("  luaL_checkany       -> shared by luaB_pcall, luaB_xpcall,")
    print("                          luaB_tostring, luaB_assert")
    print("  lua_pcall           -> luaB_pcall AND luaB_xpcall (their")
    print("                          dominant non-checkany call)")
    print("  lua_settop          -> luaB_xpcall has an explicit `lua_settop(L,2)`,")
    print("                          look for `push 2; push <L>; call ...`")
    print("  lua_gettop          -> first call in luaB_print and luaB_select")
    print("  lua_tolstring       -> luaB_print uses it via `lua_tostring` macro")
    print("                          (3-arg call with last arg = 0/NULL); also")
    print("                          last call of luaB_tostring")
    print("  luaL_loadbuffer     -> luaB_loadstring (use this directly; the")
    print("                          public 'luaL_loadstring' is just")
    print("                          `luaL_loadbuffer(L, s, strlen(s), s)`)")
    print("  luaL_checklstring   -> luaB_loadstring (called right before")
    print("                          luaL_loadbuffer)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
