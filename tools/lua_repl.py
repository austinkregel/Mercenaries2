"""Interactive Lua REPL that talks to the Merc2Fix bridge over localhost.

Protocol (matches dllmain.cpp::BridgeServerThread):
  * Connect to 127.0.0.1:27050.
  * Send Lua source, one or more lines at a time.
  * Terminate a chunk with a blank line OR a literal line `<<<RUN>>>`.
  * The bridge echoes back execution results, async Lua print() output,
    and one-line error/status markers like `[ok]`, `[compile] ...`,
    `[runtime] ...`.

Usage:
  py tools/lua_repl.py                    # interactive REPL
  py tools/lua_repl.py < some_chunk.lua   # one-shot: pipe a file in

Tips once connected:
  * `return 1+1` prints `2`.
  * `for k,v in pairs(_G) do print(type(v), k) end` dumps the entire
    global table — that's how T6 finds the cheat-menu opener.
  * Blank line is the default "execute this chunk" signal.
"""

from __future__ import annotations

import socket
import sys
import threading
import time

HOST = "127.0.0.1"
PORT = 27050
SENTINEL = "<<<RUN>>>"
END_MARKER = "<<<END>>>"
# Generous default: in-game pumps walk ~30k C++ false-positives through
# LooksLikeLuaState before catching a real Lua dispatch. 120s is enough
# for that path on a slow system; trivial chunks return in milliseconds
# regardless because we wait on the end marker, not a fixed clock.
CHUNK_TIMEOUT_SECONDS = 120.0


def reader_loop(sock: socket.socket, stop: threading.Event,
                end_event: threading.Event) -> None:
    while not stop.is_set():
        try:
            data = sock.recv(4096)
        except OSError:
            data = b""
        if not data:
            print("\n[disconnected]", flush=True)
            stop.set()
            return
        text = data.decode("utf-8", "replace")
        sys.stdout.write(text)
        sys.stdout.flush()
        if END_MARKER in text:
            end_event.set()


def main() -> int:
    try:
        sock = socket.create_connection((HOST, PORT), timeout=3)
    except OSError as e:
        print(f"connect {HOST}:{PORT} failed: {e}", file=sys.stderr)
        print("is the game running with Merc2Fix.asi loaded?", file=sys.stderr)
        return 1
    sock.settimeout(None)
    print(f"connected to lua bridge at {HOST}:{PORT}")
    print("type Lua; blank line (or `<<<RUN>>>`) executes the chunk.")
    print("ctrl-d / ctrl-z to quit.\n")

    stop = threading.Event()
    end_event = threading.Event()
    reader = threading.Thread(target=reader_loop, args=(sock, stop, end_event), daemon=True)
    reader.start()

    interactive = sys.stdin.isatty()

    try:
        if interactive:
            # Interactive: blank line or `<<<RUN>>>` flushes the buffered
            # chunk. Each chunk fires independently so you can iterate.
            buf: list[str] = []
            prompt = "lua> "
            cont_prompt = ".... "
            while not stop.is_set():
                sys.stdout.write(prompt if not buf else cont_prompt)
                sys.stdout.flush()
                try:
                    line = sys.stdin.readline()
                except KeyboardInterrupt:
                    print()
                    break
                if not line:  # EOF
                    break
                line = line.rstrip("\n")
                stripped = line.strip()
                if stripped == SENTINEL or stripped == "":
                    if buf:
                        end_event.clear()
                        chunk = "\n".join(buf) + "\n" + SENTINEL + "\n"
                        try:
                            sock.sendall(chunk.encode("utf-8"))
                        except OSError as e:
                            print(f"\n[send failed: {e}]", file=sys.stderr)
                            break
                        buf.clear()
                        if not end_event.wait(timeout=CHUNK_TIMEOUT_SECONDS):
                            print(f"\n[timeout after {CHUNK_TIMEOUT_SECONDS:.0f}s — "
                                  f"pump never fired or chunk crashed]", file=sys.stderr)
                else:
                    buf.append(line)
        else:
            # Piped (`py lua_repl.py < some.lua`): blank lines inside the
            # file are NOT chunk delimiters — they're just whitespace
            # between comment blocks and code. Read the whole stream,
            # send it as one chunk, wait for the end marker.
            chunk_body = sys.stdin.read()
            if chunk_body.strip():
                end_event.clear()
                if not chunk_body.endswith("\n"):
                    chunk_body += "\n"
                chunk = chunk_body + SENTINEL + "\n"
                try:
                    sock.sendall(chunk.encode("utf-8"))
                except OSError as e:
                    print(f"\n[send failed: {e}]", file=sys.stderr)
                else:
                    if not end_event.wait(timeout=CHUNK_TIMEOUT_SECONDS):
                        print(f"\n[timeout after {CHUNK_TIMEOUT_SECONDS:.0f}s — "
                              f"pump never fired or chunk crashed]", file=sys.stderr)
    finally:
        stop.set()
        try:
            sock.shutdown(socket.SHUT_RDWR)
        except OSError:
            pass
        sock.close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
