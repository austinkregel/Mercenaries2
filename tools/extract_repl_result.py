"""Strip the REPL transport framing out of a captured `lua_repl.py`
session, leaving just the Lua chunk's returned string contents.

Input (e.g. globals_ingame_raw.txt) looks like:

    connected to lua bridge at 127.0.0.1:27050
    type Lua; blank line (or `<<<RUN>>>`) executes the chunk.
    ctrl-d / ctrl-z to quit.

    [queued]
    [runtime] <tt=2 val=40000014> "entries: 8415
    ASSERT	function
    Ai	table
    ...
    xpcall	function"
    <<<END>>>

Output: just the lines between the opening `"` (after the [runtime]
prefix) and the closing `"<<<END>>>` pair.

Usage: py tools/extract_repl_result.py out/globals_ingame_raw.txt > out/globals_ingame.txt
"""
from __future__ import annotations

import re
import sys


RESULT_LINE = re.compile(r'^\[(?:ok|runtime|compile|bridge)\][^"]*"')


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: extract_repl_result.py <raw_repl_log>", file=sys.stderr)
        return 2
    with open(sys.argv[1], "r", encoding="utf-8", errors="replace") as f:
        lines = f.readlines()

    out: list[str] = []
    state = "before"  # before -> inside -> done

    for line in lines:
        stripped = line.rstrip("\n")
        if state == "before":
            m = RESULT_LINE.match(stripped)
            if m:
                rest = stripped[m.end():]
                out.append(rest)
                state = "inside"
        elif state == "inside":
            if stripped == "<<<END>>>":
                # The previous line we appended was the last content line;
                # it should end with a closing `"`. Strip it.
                if out and out[-1].endswith('"'):
                    out[-1] = out[-1][:-1]
                state = "done"
                break
            out.append(stripped)

    if state != "done":
        print("warning: never saw <<<END>>>; output may be incomplete",
              file=sys.stderr)

    sys.stdout.write("\n".join(out))
    if out:
        sys.stdout.write("\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
