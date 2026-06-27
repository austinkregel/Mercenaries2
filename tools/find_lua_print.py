"""Locate luaB_print (and as many other engine-registered Lua C functions
as possible) inside a static-linked Lua 5.1 game binary.

Strategy:
  1. Parse the PE headers, walk every section.
  2. Index every short null-terminated ASCII string (the kinds that would
     plausibly appear as a Lua function name) by its virtual address.
  3. Treat every section as a haystack of 4-byte little-endian DWORDs and
     look for runs of the shape  (string_va, code_va, string_va, code_va, ...)
     ending in (0, 0) or (0, nullable) — that's a luaL_Reg array.
  4. Print every such array found, named by its first entry.

Run:
    py tools/find_lua_print.py "C:\\Games\\Mercenaries 2 World in Flames\\Mercenaries2.exe.bak"

The .bak is the untouched copy — preferred over the (possibly Merc2Fix-mutated)
live exe. Either will work; only the strings/code sections are read.
"""

from __future__ import annotations

import struct
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


# --- PE parsing (just enough) ----------------------------------------------

@dataclass
class Section:
    name: str
    virtual_size: int
    virtual_address: int      # RVA
    size_of_raw_data: int
    pointer_to_raw_data: int  # file offset
    characteristics: int
    data: bytes               # raw bytes from disk (may be all-zero if packed)

    @property
    def is_executable(self) -> bool:
        return bool(self.characteristics & 0x20000000)

    def contains_va(self, va: int, image_base: int) -> bool:
        rva = va - image_base
        return self.virtual_address <= rva < self.virtual_address + max(
            self.virtual_size, self.size_of_raw_data
        )

    def va_to_file_offset(self, va: int, image_base: int) -> Optional[int]:
        rva = va - image_base
        off = rva - self.virtual_address
        if 0 <= off < self.size_of_raw_data:
            return self.pointer_to_raw_data + off
        return None


@dataclass
class PE:
    image_base: int
    sections: list[Section]
    raw: bytes

    @classmethod
    def parse(cls, path: Path) -> "PE":
        raw = path.read_bytes()
        if raw[:2] != b"MZ":
            raise ValueError("not a PE: missing MZ")
        e_lfanew = struct.unpack_from("<I", raw, 0x3C)[0]
        if raw[e_lfanew : e_lfanew + 4] != b"PE\x00\x00":
            raise ValueError("not a PE: missing PE signature")

        # COFF header
        coff = e_lfanew + 4
        num_sections = struct.unpack_from("<H", raw, coff + 2)[0]
        opt_header_size = struct.unpack_from("<H", raw, coff + 16)[0]

        opt = coff + 20
        magic = struct.unpack_from("<H", raw, opt)[0]
        if magic == 0x10B:
            image_base = struct.unpack_from("<I", raw, opt + 28)[0]
        elif magic == 0x20B:
            image_base = struct.unpack_from("<Q", raw, opt + 24)[0]
        else:
            raise ValueError(f"unknown PE optional header magic 0x{magic:04x}")

        # Section table immediately follows the optional header.
        sec_off = opt + opt_header_size
        sections: list[Section] = []
        for i in range(num_sections):
            entry = sec_off + i * 40
            name = raw[entry : entry + 8].rstrip(b"\x00").decode("latin-1")
            vs, va, raw_size, raw_ptr = struct.unpack_from("<IIII", raw, entry + 8)
            chars = struct.unpack_from("<I", raw, entry + 36)[0]
            sec_bytes = raw[raw_ptr : raw_ptr + raw_size]
            sections.append(
                Section(
                    name=name,
                    virtual_size=vs,
                    virtual_address=va,
                    size_of_raw_data=raw_size,
                    pointer_to_raw_data=raw_ptr,
                    characteristics=chars,
                    data=sec_bytes,
                )
            )
        return cls(image_base=image_base, sections=sections, raw=raw)

    def section_for_va(self, va: int) -> Optional[Section]:
        for s in self.sections:
            if s.contains_va(va, self.image_base):
                return s
        return None

    def is_likely_text_va(self, va: int) -> bool:
        s = self.section_for_va(va)
        return s is not None and s.is_executable


# --- string indexing --------------------------------------------------------

# Lua C-function names are short identifiers: lowercase, digits, underscore.
# We're indexing strings that *might* be Lua names. Permissive — we'll filter
# later by checking which strings actually show up as luaL_Reg keys.
_NAME_CHARSET = set(b"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_")


def index_strings(pe: PE) -> dict[int, str]:
    """Map each plausible function-name string's VA to its text.

    A plausible name is a NUL-terminated run of length 2..40 from _NAME_CHARSET,
    where the byte BEFORE the run is also a NUL (so we don't catch substrings
    inside larger strings).
    """
    out: dict[int, str] = {}
    for sec in pe.sections:
        data = sec.data
        n = len(data)
        i = 0
        while i < n:
            # Only start a candidate immediately after a NUL.
            if i > 0 and data[i - 1] != 0 and i != 0:
                # find next NUL and continue
                nxt = data.find(b"\x00", i)
                i = (nxt + 1) if nxt != -1 else n
                continue
            j = i
            while j < n and data[j] in _NAME_CHARSET:
                j += 1
            if j < n and data[j] == 0:
                length = j - i
                if 2 <= length <= 40:
                    s = data[i:j].decode("ascii")
                    va = pe.image_base + sec.virtual_address + i
                    out[va] = s
                i = j + 1
            else:
                # not a valid candidate, skip to next NUL
                nxt = data.find(b"\x00", j)
                i = (nxt + 1) if nxt != -1 else n
    return out


# --- luaL_Reg scanning ------------------------------------------------------

@dataclass
class RegArray:
    section_name: str
    file_offset: int
    va: int
    entries: list[tuple[str, int]]  # (name, code_va)
    terminated: bool                # ends with (0, 0)


def scan_reg_arrays(
    pe: PE,
    name_by_va: dict[int, str],
    min_entries: int = 3,
) -> list[RegArray]:
    """Find arrays of (name_ptr, code_ptr) pairs terminated by (0, 0).

    Walks every section as little-endian DWORDs. At each aligned offset, tries
    to read a maximal run of pairs where:
      * dword #1 is a known name VA (from name_by_va)
      * dword #2 is a VA in an executable section
    Stops when it sees (0, 0) (proper terminator) or breaks the pattern.
    Records runs of length >= min_entries.
    """
    found: list[RegArray] = []
    for sec in pe.sections:
        data = sec.data
        n = len(data)
        # luaL_Reg is 8 bytes on x86; engine arrays are usually 4-byte aligned.
        for off in range(0, n - 8, 4):
            # Quick reject: must look like name_ptr (nonzero) at the start.
            n1, c1 = struct.unpack_from("<II", data, off)
            if n1 == 0 or n1 not in name_by_va:
                continue
            if c1 == 0 or not pe.is_likely_text_va(c1):
                continue

            entries: list[tuple[str, int]] = []
            cur = off
            terminated = False
            while cur + 8 <= n:
                np, cp = struct.unpack_from("<II", data, cur)
                if np == 0 and cp == 0:
                    terminated = True
                    cur += 8
                    break
                if np in name_by_va and pe.is_likely_text_va(cp):
                    entries.append((name_by_va[np], cp))
                    cur += 8
                else:
                    break

            if len(entries) >= min_entries:
                file_off = sec.pointer_to_raw_data + off
                va = pe.image_base + sec.virtual_address + off
                found.append(
                    RegArray(
                        section_name=sec.name,
                        file_offset=file_off,
                        va=va,
                        entries=entries,
                        terminated=terminated,
                    )
                )
    return found


# --- pretty output ----------------------------------------------------------

# Canonical Lua 5.1 base library function names (luaB_*).
LUA_BASE_NAMES = {
    "assert", "collectgarbage", "dofile", "error", "gcinfo", "getfenv",
    "getmetatable", "ipairs", "loadfile", "load", "loadstring", "next",
    "pcall", "print", "rawequal", "rawget", "rawset", "select",
    "setfenv", "setmetatable", "tonumber", "tostring", "type", "unpack",
    "xpcall", "newproxy",
}


def categorize(arr: RegArray) -> str:
    """Best-effort label for a registered library."""
    names = {n for n, _ in arr.entries}
    if names & {"print", "pcall", "tostring", "type"}:
        return "Lua base library (luaB_*)"
    if names & {"format", "gmatch", "gsub", "find", "byte"}:
        return "Lua string library"
    if names & {"insert", "remove", "concat", "sort"}:
        return "Lua table library"
    if names & {"sin", "cos", "sqrt", "floor", "ceil"}:
        return "Lua math library"
    if names & {"open", "close", "read", "write", "lines"}:
        return "Lua io library"
    if names & {"date", "time", "clock", "getenv"}:
        return "Lua os library"
    if names & {"sethook", "gethook", "getinfo", "traceback"}:
        return "Lua debug library"
    return "engine-registered Lua C functions"


def main() -> int:
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    path = Path(sys.argv[1])
    pe = PE.parse(path)

    print(f"loaded {path}")
    print(f"  image_base = 0x{pe.image_base:08x}")
    print(f"  sections:")
    for s in pe.sections:
        nonzero = sum(1 for b in s.data[:4096] if b)  # quick liveness sample
        print(
            f"    {s.name:<8}  va=0x{s.virtual_address:08x}  vs=0x{s.virtual_size:08x}  "
            f"rsz=0x{s.size_of_raw_data:08x}  exec={s.is_executable}  "
            f"live={nonzero}/4096"
        )

    name_by_va = index_strings(pe)
    print(f"\nindexed {len(name_by_va):,} candidate name strings")

    arrays = scan_reg_arrays(pe, name_by_va, min_entries=3)
    print(f"found {len(arrays)} candidate luaL_Reg arrays\n")

    # Sort: terminated arrays first, then by size.
    arrays.sort(key=lambda a: (not a.terminated, -len(a.entries)))

    for arr in arrays:
        label = categorize(arr)
        term = "term" if arr.terminated else "open"
        print(
            f"=== {label} :: {len(arr.entries)} entries [{term}] "
            f"@ file=0x{arr.file_offset:08x} va=0x{arr.va:08x} sec={arr.section_name}"
        )
        for name, code_va in arr.entries:
            code_rva = code_va - pe.image_base
            print(f"    {name:<24}  0x{code_va:08x}  (RVA 0x{code_rva:08x})")
        print()

    # Highlight luaB_print specifically.
    print_addr: Optional[int] = None
    for arr in arrays:
        for name, code_va in arr.entries:
            if name == "print" and any(
                n in LUA_BASE_NAMES for n, _ in arr.entries if n != "print"
            ):
                print_addr = code_va
                break
        if print_addr:
            break
    print("---")
    if print_addr is not None:
        rva = print_addr - pe.image_base
        print(f"luaB_print VA  = 0x{print_addr:08x}")
        print(f"luaB_print RVA = 0x{rva:08x}   <-- put this in kLuaPrintRVA")
    else:
        print("luaB_print: NOT FOUND (no luaL_Reg array contained 'print' alongside other base names)")
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
