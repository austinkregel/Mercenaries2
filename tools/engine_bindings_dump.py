"""Parse tools/scan_output.txt (from find_lua_print.py) into a clean,
deduplicated, searchable catalogue of every Lua C function the engine
registers, with special handling for the shared "no-op stub" that's
reused under many names.

Outputs three files into tools/:
  - bindings_all.txt     — every unique {name, addr} pair, sorted by name
  - bindings_by_addr.txt — grouped by address, showing aliases (multiple
                            names mapped to the same fn — the noop stub
                            at 0x6AEF90 is the obvious one but engines
                            often share helpers too)
  - bindings_debug.txt   — name-keyword shortlist for things that sound
                            like debug / cheat / menu / dev functions
                            (skip / mission / spawn / give / unlock /
                            console / test / god — and a few more)

Also prints a triage summary to stdout: how many unique names, how many
real distinct functions, top categories.

Run:
    py tools/engine_bindings_dump.py
"""

from __future__ import annotations

import re
import sys
from collections import defaultdict
from pathlib import Path

# Stable input/output paths (relative to this file's location).
HERE = Path(__file__).resolve().parent
SCAN = HERE / "scan_output.txt"
OUT_ALL   = HERE / "bindings_all.txt"
OUT_BYADDR = HERE / "bindings_by_addr.txt"
OUT_DEBUG = HERE / "bindings_debug.txt"

# RVAs of known "stubbed" addresses — functions where the engine kept the
# Lua-side name registered but replaced the body with `xor eax,eax; ret`.
# These were stripped from the retail build. We mark them so you don't
# waste time investigating something that does nothing.
NOOP_VA = 0x006AEF90

# A single luaL_Reg entry line from the scan, e.g.:
#     "    print                                    -> 0x006AEF90 ..."
# scan_output.txt lines look like:
#     "    print                     0x006aef90  (RVA 0x002aef90)"
ENTRY_RE = re.compile(
    r"^    (?P<name>\S+)\s+0x(?P<va>[0-9a-fA-F]+)\s+\(RVA 0x[0-9a-fA-F]+\)\s*$"
)

# Keywords that suggest debug / cheat / dev / menu intent.
DEBUG_KEYWORDS = [
    "debug", "cheat", "dev", "console", "test", "god",
    "menu", "skip", "spawn", "give", "unlock", "noclip",
    "kill", "teleport", "tp_", "warp", "summon", "mission",
    "hierarchy", "traverse", "trigger", "eval", "exec",
    "run", "load", "script",
]


def parse_scan(path: Path) -> list[tuple[str, int]]:
    """Return every (name, va) pair seen across all candidate arrays.
    Duplicates are kept here; we dedupe later."""
    pairs: list[tuple[str, int]] = []
    with path.open("r", encoding="utf-8", errors="replace") as f:
        for line in f:
            m = ENTRY_RE.match(line.rstrip("\n"))
            if m:
                pairs.append((m.group("name"), int(m.group("va"), 16)))
    return pairs


def main() -> int:
    if not SCAN.exists():
        print(f"missing {SCAN} — run find_lua_print.py first")
        return 1

    pairs = parse_scan(SCAN)
    print(f"parsed {len(pairs):,} raw {{name, addr}} pairs from scan_output.txt")

    # Dedupe by exact (name, addr) — the same pair often appears across
    # multiple overlapping array detections.
    unique_pairs = sorted(set(pairs))
    names = {name for name, _ in unique_pairs}
    addrs = {addr for _, addr in unique_pairs}
    print(f"  → {len(unique_pairs):,} unique (name, addr) pairs")
    print(f"  → {len(names):,} distinct names")
    print(f"  → {len(addrs):,} distinct function addresses")

    # Group names by address to find aliases.
    by_addr: dict[int, list[str]] = defaultdict(list)
    for name, addr in unique_pairs:
        by_addr[addr].append(name)
    for v in by_addr.values():
        v.sort()

    aliased = {a: names for a, names in by_addr.items() if len(names) > 1}
    print(f"  → {len(aliased):,} addresses have multiple aliases")
    noop_aliases = by_addr.get(NOOP_VA, [])
    print(f"  → {len(noop_aliases):,} functions are stubbed to the noop @ 0x{NOOP_VA:08X}")

    # ---- bindings_all.txt: every name, sorted ----
    with OUT_ALL.open("w", encoding="utf-8") as f:
        f.write(f"# Every unique Lua C function name the engine registers.\n")
        f.write(f"# {len(unique_pairs)} pairs, {len(names)} distinct names.\n")
        f.write(f"# A trailing [STUB] marks the noop stub at 0x{NOOP_VA:08X}\n")
        f.write(f"# (function was stripped from the retail build).\n\n")
        f.write(f"{'name':<48}  {'address':<10}  notes\n")
        f.write("-" * 80 + "\n")
        for name, addr in sorted(unique_pairs, key=lambda p: p[0].lower()):
            stub = "  [STUB]" if addr == NOOP_VA else ""
            f.write(f"{name:<48}  0x{addr:08X}{stub}\n")
    print(f"  wrote {OUT_ALL}")

    # ---- bindings_by_addr.txt: addresses with their aliases ----
    with OUT_BYADDR.open("w", encoding="utf-8") as f:
        f.write(f"# Engine Lua C functions grouped by address.\n")
        f.write(f"# Addresses with multiple names = aliases (same compiled body\n")
        f.write(f"# registered under several Lua-side names — the noop stub at\n")
        f.write(f"# 0x{NOOP_VA:08X} is the most extreme example).\n\n")
        for addr in sorted(by_addr.keys()):
            ns = by_addr[addr]
            marker = "  [STUB]" if addr == NOOP_VA else ""
            f.write(f"0x{addr:08X}{marker}  ({len(ns)} name{'s' if len(ns) > 1 else ''})\n")
            for n in ns:
                f.write(f"    {n}\n")
            f.write("\n")
    print(f"  wrote {OUT_BYADDR}")

    # ---- bindings_debug.txt: debug-shaped names ----
    debug_hits: list[tuple[str, int]] = []
    for name, addr in unique_pairs:
        ln = name.lower()
        if any(kw in ln for kw in DEBUG_KEYWORDS):
            debug_hits.append((name, addr))
    debug_hits.sort(key=lambda p: (p[1] == NOOP_VA, p[0].lower()))
    with OUT_DEBUG.open("w", encoding="utf-8") as f:
        f.write(f"# Functions whose name matches a debug/cheat/dev/menu keyword.\n")
        f.write(f"# Keyword set: {', '.join(DEBUG_KEYWORDS)}\n")
        f.write(f"# Sorted so REAL functions (not stubbed) appear first.\n\n")
        f.write(f"{'name':<48}  {'address':<10}  notes\n")
        f.write("-" * 80 + "\n")
        for name, addr in debug_hits:
            stub = "  [STUB - stripped from retail]" if addr == NOOP_VA else ""
            f.write(f"{name:<48}  0x{addr:08X}{stub}\n")
        f.write(f"\n# {len(debug_hits)} matches total, "
                f"{sum(1 for _, a in debug_hits if a != NOOP_VA)} real / "
                f"{sum(1 for _, a in debug_hits if a == NOOP_VA)} stubbed.\n")
    print(f"  wrote {OUT_DEBUG}  ({len(debug_hits)} keyword hits)")

    # Triage summary
    print("\n=== summary ===")
    real_addrs = [a for a in addrs if a != NOOP_VA]
    print(f"  {len(real_addrs):,} distinct REAL engine functions")
    print(f"  {len(noop_aliases):,} stripped (stub'd) function names")
    real_debug = [(n, a) for n, a in debug_hits if a != NOOP_VA]
    print(f"  {len(real_debug):,} debug-keyword matches that are REAL functions")
    if real_debug[:30]:
        print("\n  top 30 real debug-shaped names (these are the cheat-menu candidates):")
        for name, addr in sorted(real_debug)[:30]:
            print(f"    {name:<44}  0x{addr:08X}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
