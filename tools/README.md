# Merc2Reborn — tools/

Build-time helpers and runtime test harnesses for the Lua bridge.

## Static analysis

These run against `Mercenaries2.exe.bak` and produce the RVAs that get
baked into `dllmain.cpp`. Re-run if the binary changes.

- `find_lua_print.py` — PE parser + `luaL_Reg` scanner. Locates
  `luaB_print` and dumps every Lua C function the engine registers (the
  scan also surfaces 1000+ engine bindings — invaluable for T6).
- `resolve_lua_api.py` — Capstone-based call-graph walker. Disassembles
  the thin Lua base-library wrappers (`luaB_pcall`, `luaB_xpcall`, …) and
  follows their `call rel32` targets to identify the internal API
  (`lua_pcall`, `lua_settop`, `lua_tolstring`, `luaL_loadbuffer`).
- `lua_api_findings.md` — distilled output of the above two: the final
  RVA table that `dllmain.cpp` consumes, with confidence levels and notes
  on what was tricky (Lua's `print` is a no-op stub, debug lib is stripped,
  `lua_gettop` is inlined everywhere, …).

Requires: `py -m pip install capstone` (no other deps).

## Runtime

- `lua_console.py` — **the nice one.** Single-file tkinter IDE
  (stdlib only, no pip installs). Tabbed editor with Lua syntax
  highlighting + line numbers, persistent output panel, save/open
  .lua files, recent files, bridge status indicator. `Ctrl+Enter` or
  `F5` to execute. Run with `py tools/lua_console.py`. **Also shipped
  as a standalone `lua_console.exe`** inside the "full" release zip
  (PyInstaller-frozen, no Python required) — that's what end users
  get on download.
- `tools.json` — companion-tool manifest shipped alongside
  `lua_console.exe` in the release zip. Proposes a small format so
  any mod manager (e.g. mercs2-modkit) can surface a "Launch Tool"
  button on this mod's page. Not a standard yet — starting point
  for that conversation with the framework devs.
- `lua_repl.py` — bare-bones interactive client for the localhost
  bridge. Connects to `127.0.0.1:27050` once the game is running
  with the new ASI loaded. Blank line executes the buffered chunk
  in interactive mode; pipe a `.lua` file for one-shot use.
- `enum_globals.lua` — dump `_G` as `<type>\t<name>` lines.
- `find_menu.lua` — pattern-match likely cheat-menu opener names.
- `probe_namespaces.lua` — enumerate fields of common engine namespaces
  (`Debug`, `Cheats`, `Game`, `Console`, etc.).

Pipe a `.lua` file in for one-shot use, e.g.:

```
py tools/lua_repl.py < tools/enum_globals.lua > globals.txt
```

## Acceptance sequence (matches the work brief)

1. Rebuild `Merc2Fix.asi` (Release), drop it in the game install dir.
2. Launch via dxwrapper. Tail `Merc2Debug.log` until you see
   `Lua state captured via …`.
3. `py tools/lua_repl.py` → `return 1+1` → blank line → expect `2`.
4. Stress: paste a 100-iteration loop, confirm no crash.
5. `py tools/lua_repl.py < tools/find_menu.lua` → review candidates.
6. Call the most-likely opener; if the menu renders, save the call as
   `cheatmenu.lua`.
