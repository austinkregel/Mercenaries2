# Engine Mapping Handoff Brief

## Project context

Merc2Reborn is a revival of Mercenaries 2: World in Flames (2008,
Pandemic Studios). A C++ ASI bridge (`Merc2Fix/`) has been built that
hooks the game's statically-linked Lua 5.1.2 runtime and exposes
arbitrary Lua execution over `127.0.0.1:27050`. Your job is to
continue mapping the engine's Lua API surface so we can write mods.

The bridge works. Focus on probing, not on bridge internals.

## How to drive the bridge

Prereqs: game must be running with `Merc2Fix.asi` loaded (deploys to
`C:\Games\Mercenaries 2 World in Flames\`). The bridge listens on
`127.0.0.1:27050`. Standard workflow:

```bash
# 1. Write a Lua probe
$EDITOR tools/probe_X.lua

# 2. Run it; raw output goes to out/probe_X.txt
py tools/lua_repl.py < tools/probe_X.lua > out/probe_X.txt 2>&1

# 3. Strip transport framing to get just the chunk's return string
py tools/extract_repl_result.py out/probe_X.txt
```

## Probe methodology (the pattern that works)

- **Multi-return capture**: Lua functions often return tuples
  (`GetPosition` returns x,y,z). Naive `local ok, val = pcall(fn)`
  loses everything past the first return. Use a select-based capture
  helper — see `tools/probe_object_full.lua` for the template.
- **Mutator verification**: read state → mutate by small delta →
  re-read → revert. Confirms signature, return shape, and reversibility
  in one chunk. See `tools/probe_attached_and_cash.lua`.
- **Sub-table walks**: when a namespace has lots of entries but few
  direct functions (e.g. `Hud`), it's all in sub-tables. Walk one level
  deeper with `pairs(NS.SubTable)` per sub-name.
- **One probe = one chunk ≤ ~3.5 KB**. The bridge has a 4 KB chunk
  source cap; split larger probes into multiple files.
- **Try no-arg first**, then with the most-likely handle. Error
  messages from `pcall` often hint at the real signature.

## Critical gotchas (don't rediscover these)

1. **TValue is 8 bytes**, not stock-Lua 16 — Pandemic built with
   `lua_Number = float`. Only matters if you touch the C bridge; Lua
   scripts see normal semantics.
2. **`luaB_pcall` is non-stock** — leaves junk at slot 0, real chunk
   return values at slot 1 onwards. The `[runtime]` vs `[ok]` label
   from the bridge is cosmetic — trust the data, not the label.
3. **`lua_repl.py` in piped mode** reads the entire stream as one
   chunk (does NOT split on blank lines — already fixed). The 120 s
   timeout is enough for in-game pumps.
4. **In-game pump latency**: when the engine is in active gameplay,
   the bridge's noop-stub detour walks ~30k C++ false-positives
   before catching a valid Lua dispatch. So expect a single chunk to
   take a few seconds to drain mid-game. Don't shorten the timeout.
5. **Bridge log** at
   `C:\Games\Mercenaries 2 World in Flames\Merc2Debug.log` shows
   what the C side observed (capture events, queued chunks, results).
   Always check the log if a chunk seems to not run.
6. **HQ is invincibility mode** — `Object.GetInvincible(char) ==
   true` in HQ because weapons are stripped; not a default state.

## What's already mapped (don't redo)

- **`Player.*`** — all major getters, handle numbering pattern,
  multi-return shapes. See "VERIFIED — Player.* reference" in
  `tools/engine_api.md`.
- **`Object.*`** — full getter coverage on a character handle. See
  the same doc.
- **Mutator pattern** (`Player.AddCash`) — confirmed: signed delta,
  void return, exactly reversible.
- **Equipment slots** via `Object.GetAttachedObjects(char)`.
- **The cheat menu opener**: `Cheat.DisplayOptions()`.
- **8415-entry runtime surface** captured in `out/globals_ingame.txt`
  (clean) and `out/globals_ingame_raw.txt` (REPL transcript).

## Suggested next targets (priority order)

1. **`Hud.*` sub-tables** (`Announcement`, `ClassyText`, `Fanfare`,
   etc.) — never enumerated. Best lead for "render text on screen".
2. **`Net.SendEvent_*` family** (32+ functions) — signatures
   unknown; most are typed broadcasts the game uses for its own UI
   events. Likely each takes a small arg tuple. Cheapest to probe by
   trying no-args first.
3. **`Vehicle.*`** — needs to be done with the player actually in a
   vehicle. Same probe pattern as Object.
4. **`Ai.*`** (66 entries) — NPC behavior, faction relations.
5. **`Pda.Map.*`** — mission marker manipulation.
6. **Localization lookup** — `Object.GetLocalizedName` returns
   hashes like `"[0xb7f587a3]"`. Find the table that resolves them
   into readable strings. There's likely a `Sys.*` helper or a
   `String.*` table entry we haven't probed.

## When you make progress

Update `tools/engine_api.md` — append to the "VERIFIED" sections in
the same format. **Only put verified data there**; speculative
guesses go under "Signature unknowns worth verifying" so they're not
mistaken for confirmed.

Reference the relevant probe script in your additions so a future
reader can re-run them.
