# Mercenaries2.exe — Lua 5.1.2 API resolution (T1 output)

Image base: `0x00400000`. All RVAs verified against `Mercenaries2.exe.bak`
(the pre-launch backup).

## Capture targets (hook these to grab `lua_State*` from arg 0)

| Symbol               | RVA           | Notes |
|----------------------|---------------|-------|
| `luaB_print`         | `0x002AEF90`  | **Shared no-op stub** (`xor eax,eax; ret`). NOT just `print` — the same compiled function is registered under many other names too (`SendEvent_AddObjective`, `SendEvent_RemoveObjective`, `SetSourceEnterMusic`, `SetSourceExitMusic`, `SetCinematicMode`, `AddFadeCategory`, `_SummonEd`, …). Hooking it captures L whenever scripts call ANY of these stubs, which gives a much higher fire frequency than `print()` alone. |
| `luaB_type`          | `0x00460E90`  | Real function. Lua scripts call `type(x)` constantly — high-confidence fallback. |
| `CreateTextWidget`   | `0x001B7D30`  | Engine binding (`lua_CFunction`). The main menu creates text widgets immediately → guaranteed early capture. |

Strategy: hook all three. First detour to fire stores `g_LuaState`; others
become no-op pass-throughs after that.

## Execution API (resolved via call-graph from base-library wrappers)

| Symbol              | RVA           | Confidence | How found |
|---------------------|---------------|------------|-----------|
| `lua_pcall`         | `0x00468CF0`  | Definite   | `luaB_pcall` + `luaB_xpcall` both call it as their main work |
| `luaL_loadbuffer`   | `0x00461190`  | Medium     | `luaB_loadstring` tail-jmps to it (the `jmp 0x00461190` at end) |
| `lua_settop`        | `0x0045F2C0`  | High       | `luaB_error` calls it explicitly: `lua_settop(L, 1)` after `optint` |
| `lua_tolstring`     | `0x0046B480`  | High       | `luaB_select` calls it for `*lua_tostring(L,1) == '#'` check |

`lua_gettop` is **inlined everywhere** (it's just `L->top - L->base`).
Workaround: in `LuaDoString`, snapshot `L->base` and `L->top` directly
on entry, push our chunk at `saved_top` (treating it as the start of a
nested frame), and restore both pointers on the way out. The bridge
does NOT own the VM stack — the executor runs from inside a real
lua_CFunction dispatch (DetourLuaType / HijackedPrint), so the engine's
active frame at `[base..top)` must be preserved.

## Helper API (not needed by the bridge but identified as side-effects)

| Symbol              | RVA           | Confidence | How found |
|---------------------|---------------|------------|-----------|
| `luaL_checkany`     | `0x0045F190`  | Definite   | 11 wrappers share |
| `luaL_checktype`    | `0x0045F270`  | Definite   | 5+ wrappers with type checks |
| `luaL_optinteger`   | `0x0045F5C0`  | High       | `unpack` / `error` / `tonumber` |
| `lua_type`          | `0x00465D50`  | High       | shared by `luaB_tostring` + `luaB_select` |

## Things to know about this binary

- **`.text` is NOT zeroed on disk.** SecuROM leaves the main `.text` /
  `.rdata` intact; its protection lives in separate `Stext` / `Sitext` /
  `.securom` overlay sections. The unpack-race wait in the existing
  `PatchFeslCAKey()` is more important for `.rdata` writes than for
  reads — but keep it as cheap insurance.
- **Lua debug library is fully stripped.** No `sethook`/`gethook`/`getinfo`
  strings anywhere. This means we can't easily locate `lua_sethook`, so
  the scaffold's `LUA_MASKCOUNT` pump is off the table. Pump instead from
  the print/type/widget detours (we're already on the Lua thread inside
  a controlled pcall frame there).
- **TValue is 8 bytes** (Value at +0, int tt at +4) — not the stock 16.
  Pandemic built with `lua_Number = float`, collapsing the Value union
  from 8 → 4 bytes. Confirmed empirically from a stack dump showing
  `saved_top - saved_base = 0x08` for a 1-arg engine call and a
  `[ptr][tt=5]` repeating pattern past it. **Any code that reads a
  number TValue must dereference 4 bytes as `float`, not 8 as
  `double`.**
- **`luaB_print` is a no-op.** Whatever the game wants to log goes through
  an engine binding instead — there's an `OutputToPIX` and almost
  certainly a `Print` or `Log` somewhere in the 1000+ engine bindings
  we recovered.
- **The engine registers MASSIVE numbers of Lua C functions** — the widget
  array alone has 114 entries; total candidate arrays is 1361. Once the
  bridge is up, `for k,v in pairs(_G) do print(type(v), k) end` should
  return a giant useful map.

## Reproducing

```
py tools/find_lua_print.py "C:\Games\Mercenaries 2 World in Flames\Mercenaries2.exe.bak"
py tools/resolve_lua_api.py "C:\Games\Mercenaries 2 World in Flames\Mercenaries2.exe.bak"
```

## Runtime surface (from 2026-06-26 in-game walk)

A full runtime enumeration via `tools/walk_globals.lua` produced 8415
string-keyed entries reachable from `_G` (saved to
`out/globals_ingame.txt`). Notable for cheat-menu / debug work:

| Lua symbol               | Notes |
|--------------------------|-------|
| `Cheat.DisplayOptions()` | **The dev cheat menu opener.** Verified rendering in-game. |
| `Debug.Printf`           | Real, callable. Use for script-side logging. |
| `Debug.GetCallstack`     | Useful for tracing what's running. |
| `Debug.LogError/Warning/Info` | Tiered logging. |
| `Sys.SetSkipMission`     | Likely backs cheat menu's "Skip to a mission". |
| `Sys.GetSkipMission`     | Read-side of above. |
| `DebugTeleport`          | Global function, name self-explanatory. |
| `Pda.Map.*Mission*`      | Mission management surface (Add/Remove/Update/Track). |
| `_MODULES`               | 6837 entries — every loaded Lua module is here. |

## Executor gotchas worth knowing if you re-derive this

- **TValue is 8 bytes** (Pandemic built with `lua_Number = float`).
  Not 16. See the dedicated bullet above.
- **`luaL_register` is called with `libname = "_G"`** when registering
  the basic library. Hijacks gating on `libname == NULL` will never
  fire — match `"_G"` instead.
- **`LuaDoString` must build a nested frame** on top of the engine's
  active frame (save base+top, set `new_base = saved_top`, push there,
  restore). Direct overwriting of `L->base[0]` clobbers the in-progress
  engine call.
- **Pandemic's `luaB_pcall` is non-stock** — it leaves junk at slot 0
  (variable: sometimes a string, sometimes nil, sometimes a number) and
  the script's actual return value at slot 1. Returns weird counts.
  Don't trust slot 0; trust slot 1 onwards for results.
