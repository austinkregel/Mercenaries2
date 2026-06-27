"""Locate the function that consumes luaL_Reg arrays (i.e. luaL_register,
luaI_openlib, or Pandemic's equivalent).

Strategy:
  1. Pick known luaL_Reg array start VAs from find_lua_print's output —
     the big base-library table is at file 0x007924B8 / VA 0x00B924B8,
     and we have many smaller tables clustered nearby.
  2. Scan every .text section for any 4-byte LE DWORD matching one of
     those VAs (the address of the table being passed as an argument).
  3. For each hit, walk backward to find the enclosing function (look for
     a recent compiler-emitted alignment or int3 padding boundary, or
     a typical prologue: 55 8B EC = push ebp; mov ebp, esp).
  4. Disassemble the first N instructions of each enclosing function so
     we can recognize the registration pattern (push libname; push table;
     push L; call X — or the engine's __fastcall/__thiscall variant).
  5. Frequency-sort: a function that loads MULTIPLE different table VAs
     is almost certainly the central registration routine.

Run:
    py tools/find_lua_register.py "C:\\Games\\Mercenaries 2 World in Flames\\Mercenaries2.exe.bak"
"""

from __future__ import annotations

import struct
import sys
from collections import Counter, defaultdict
from pathlib import Path

from capstone import Cs, CS_ARCH_X86, CS_MODE_32  # type: ignore

sys.path.insert(0, str(Path(__file__).resolve().parent))
from find_lua_print import PE, index_strings, scan_reg_arrays  # noqa: E402


def find_text_dword_xrefs(pe: PE, target_va: int) -> list[int]:
    """Return every code-section file address whose 4-byte LE DWORD == target_va."""
    hits: list[int] = []
    pat = struct.pack("<I", target_va)
    for sec in pe.sections:
        if not sec.is_executable:
            continue
        data = sec.data
        start = 0
        while True:
            i = data.find(pat, start)
            if i < 0:
                break
            # Address of the DWORD in image VA terms
            hits.append(pe.image_base + sec.virtual_address + i)
            start = i + 1
    return hits


def find_function_start(pe: PE, code_va: int, max_back: int = 0x800) -> int | None:
    """Walk backward from `code_va` to find a plausible function entry.

    Heuristics, in order:
      * a 0xCC int3 padding byte at va-1 (compilers emit int3 between
        functions for alignment) — return va
      * `8B FF` (mov edi, edi — MSVC hot-patch prologue) — return va
      * `55 8B EC` (push ebp; mov ebp, esp) — return va
      * `83 EC xx` (sub esp, imm8) at a 16-aligned address — return va
    """
    sec = pe.section_for_va(code_va)
    if sec is None:
        return None
    off = code_va - pe.image_base - sec.virtual_address
    data = sec.data
    if off >= len(data):
        return None

    end = max(0, off - max_back)
    cur = off
    while cur > end:
        cur -= 1
        if cur <= 0:
            break
        b0 = data[cur]
        if b0 == 0xCC and cur + 1 < len(data) and data[cur + 1] != 0xCC:
            return pe.image_base + sec.virtual_address + cur + 1
        # MSVC hot-patch prologue: 8B FF (mov edi, edi)
        if cur + 1 < len(data) and b0 == 0x8B and data[cur + 1] == 0xFF:
            # often preceded by alignment padding
            return pe.image_base + sec.virtual_address + cur
        # plain frame setup: 55 8B EC
        if cur + 2 < len(data) and b0 == 0x55 and data[cur + 1] == 0x8B and data[cur + 2] == 0xEC:
            return pe.image_base + sec.virtual_address + cur
    return None


def disasm_window(pe: PE, va: int, n_insns: int = 12) -> list:
    sec = pe.section_for_va(va)
    if sec is None:
        return []
    off = va - pe.image_base - sec.virtual_address
    md = Cs(CS_ARCH_X86, CS_MODE_32)
    out = []
    for insn in md.disasm(sec.data[off : off + 256], va):
        out.append(insn)
        if len(out) >= n_insns:
            break
    return out


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    pe = PE.parse(Path(sys.argv[1]))
    print(f"loaded {sys.argv[1]}, image_base=0x{pe.image_base:08x}\n")

    # Rebuild the luaL_Reg array list. We use find_lua_print's scanner
    # so we don't drift from its definitions.
    print("scanning for luaL_Reg arrays ...")
    name_by_va = index_strings(pe)
    arrays = scan_reg_arrays(pe, name_by_va, min_entries=6)
    arrays = [a for a in arrays if a.terminated]
    print(f"  found {len(arrays)} candidate arrays")

    # The arrays' starting VAs are what the registration function receives
    # as its `luaL_Reg *l` argument.
    table_vas = sorted({a.va for a in arrays})
    print(f"  {len(table_vas)} unique table starting VAs\n")

    # For each table, find code refs.
    func_table_counts: Counter[int] = Counter()  # function_va -> count of tables it loads
    func_examples: dict[int, list[tuple[int, int]]] = defaultdict(list)  # function_va -> [(xref_va, table_va)]

    print("scanning .text for cross-references to those table VAs ...")
    total_xrefs = 0
    for tva in table_vas:
        for xva in find_text_dword_xrefs(pe, tva):
            total_xrefs += 1
            func_va = find_function_start(pe, xva)
            if func_va is None:
                continue
            func_table_counts[func_va] += 1
            func_examples[func_va].append((xva, tva))
    print(f"  {total_xrefs} total xrefs across {len(func_table_counts)} candidate functions\n")

    # The registration function is the one that loads the MOST distinct
    # tables — that's the central code path every library opener goes
    # through.
    top = func_table_counts.most_common(15)
    print("=== top-15 candidate registration functions ===")
    for func_va, count in top:
        func_rva = func_va - pe.image_base
        distinct_tables = len({tva for _, tva in func_examples[func_va]})
        print(f"\n  fn @ 0x{func_va:08x}  (RVA 0x{func_rva:08x})  "
              f"loads {count} table references, {distinct_tables} distinct tables")
        for xva, tva in func_examples[func_va][:5]:
            print(f"      xref @ 0x{xva:08x}  ->  table @ 0x{tva:08x}")
        if len(func_examples[func_va]) > 5:
            print(f"      ... and {len(func_examples[func_va]) - 5} more")

        # Disasm window so we can recognize the registration pattern.
        print(f"      prologue / first instructions:")
        for ins in disasm_window(pe, func_va, n_insns=14):
            print(f"        {ins.address:08x}  {ins.bytes.hex():<14}  "
                  f"{ins.mnemonic} {ins.op_str}")

    return 0


if __name__ == "__main__":
    sys.exit(main())
