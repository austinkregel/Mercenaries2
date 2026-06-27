"""Disassemble the first N bytes at a given RVA. Use to verify what's
actually at an address and identify calling convention from the prologue.

Calling-convention tells:
  __cdecl:    `mov edi, edi; push ebp; mov ebp, esp; ...`
              args accessed as [ebp+8], [ebp+0xC], ...
              caller cleans stack (`ret` not `ret imm16`)
  __stdcall:  Same prologue, but `ret imm16` to clean stack itself.
  __fastcall: `mov edi, edi; push ebp; mov ebp, esp; sub esp, X;
              mov [ebp-?], edx; mov [ebp-?], ecx; ...`
              First two args come from ECX, EDX; rest from stack.
              The give-away is `mov [ebp-?], ecx` early in the prologue.
  __thiscall: ECX=this, rest on stack. Looks like fastcall for arg0 only.

Lua 5.1 source convention:
  - Public API decorated with LUA_API is "extern" — inherits compiler default
  - Static luaB_* / luaopen_* / etc. are file-local, also compiler default
  - lua_CFunction typedef has no convention → also compiler default

So if the WHOLE liblua compilation unit was built with /Gr (fastcall),
then ALL the Lua functions are fastcall. If built with /Gd (cdecl, default),
all cdecl. There's no "mixed" middle ground within one .obj.

Run:
    py tools/dump_function.py "C:\\Games\\Mercenaries 2 World in Flames\\Mercenaries2.exe.bak" 0x0045f2c0 [bytes_to_dump]
"""

from __future__ import annotations

import sys
from pathlib import Path

from capstone import Cs, CS_ARCH_X86, CS_MODE_32  # type: ignore

sys.path.insert(0, str(Path(__file__).resolve().parent))
from find_lua_print import PE  # noqa: E402


def classify_prologue(insns: list) -> str:
    """Heuristic calling-convention sniff from the first ~10 instructions."""
    insn_strs = [(i.mnemonic, i.op_str) for i in insns[:12]]
    has_ecx_save = any(
        m == "mov" and ("[ebp" in o or "[esp" in o) and "ecx" in o.split(",")[-1]
        for m, o in insn_strs
    )
    has_edx_save = any(
        m == "mov" and ("[ebp" in o or "[esp" in o) and "edx" in o.split(",")[-1]
        for m, o in insn_strs
    )
    # Any access of [ebp+8] / [ebp+0xc] suggests cdecl/stdcall arg read
    has_ebp_arg = any(
        "[ebp + 8]" in o or "[ebp + 0x8]" in o or "[ebp+8]" in o or
        "[ebp + 0xc]" in o or "[ebp + 0xC]" in o or "[ebp+0xc]" in o
        for m, o in insn_strs
    )
    # Check return form
    rets = [(m, o) for m, o in insn_strs if m == "ret"]
    has_ret_imm = any(o for m, o in rets if o)

    notes = []
    if has_ecx_save and has_edx_save:
        notes.append("FASTCALL (saves both ECX and EDX early)")
    elif has_ecx_save and not has_edx_save:
        notes.append("FASTCALL or THISCALL (saves ECX only)")
    elif has_ebp_arg:
        notes.append("CDECL / STDCALL (reads args from [ebp+8] etc.)")
    else:
        notes.append("UNCLEAR (no obvious arg-save or arg-read in prologue window)")

    if has_ret_imm:
        notes.append(f"caller-frees=NO (saw `ret {rets[0][1]}` -> stdcall/fastcall/thiscall)")
    elif rets:
        notes.append("caller-frees=YES (`ret` with no imm -> cdecl, OR no-arg fn)")

    return " | ".join(notes)


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    path = Path(sys.argv[1])
    rva = int(sys.argv[2], 16) if sys.argv[2].startswith("0x") else int(sys.argv[2], 16)
    nbytes = int(sys.argv[3]) if len(sys.argv) > 3 else 64

    pe = PE.parse(path)
    sec = pe.section_for_va(pe.image_base + rva)
    if sec is None:
        print(f"RVA 0x{rva:08x} is not in any section!")
        return 1

    off_in_sec = rva - sec.virtual_address
    raw = sec.data[off_in_sec : off_in_sec + nbytes]
    base_va = pe.image_base + sec.virtual_address + off_in_sec

    print(f"=== {sec.name} : RVA 0x{rva:08x} (VA 0x{base_va:08x}) ===")
    print("hex:")
    print("  " + " ".join(f"{b:02x}" for b in raw[:32]))
    if len(raw) > 32:
        print("  " + " ".join(f"{b:02x}" for b in raw[32:64]))

    md = Cs(CS_ARCH_X86, CS_MODE_32)
    insns = list(md.disasm(raw, base_va))
    print("\ndisasm:")
    for ins in insns:
        print(f"  {ins.address:08x}  {ins.bytes.hex():<14}  "
              f"{ins.mnemonic} {ins.op_str}")

    print(f"\nconvention sniff: {classify_prologue(insns)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
