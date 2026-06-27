# out/

Output captures from runtime probes and static analyzers.

## Layout

- **`refs/`** — canonical artifacts. Stable references baked into
  documentation or used by tooling. Don't churn these without
  updating the docs that point at them.
  - `globals_ingame.txt` / `globals_ingame_raw.txt` — the runtime
    walk of `_G` and reachable sub-tables (8415 entries). Authoritative
    list of every engine-exposed function we know about. Referenced by
    `tools/engine_api.md` and `tools/agent_handoff.md`.
  - `find_original.txt` / `find_bypassed.txt` / `find_register_bypassed.txt`
    — `tools/find_lua_print.py` and `tools/find_lua_register.py`
    output for the two binaries `Merc2Fix/dllmain.cpp`'s `SelectRvas`
    knows about. Re-derive RVAs against these as the baseline before
    adding a new binary fingerprint.
  - `resolve_original.txt` / `resolve_bypassed.txt` —
    `tools/resolve_lua_api.py` call-graph walks for the same two
    binaries.
  - `probe_player_full.txt` / `probe_object_full.txt` /
    `probe_attached_and_cash.txt` / `probe_signatures.txt` /
    `probe_mystery_ns.txt` / `probe_getters.txt` / `probe_object.txt`
    — the verified data behind the "VERIFIED" sections of
    `tools/engine_api.md`. Each line corresponds to a row in the doc.

- **`runs/`** — transient probe and experiment output. Where new probe
  results land by convention. Mix of successful experiments,
  validation runs, and dead ends from the engine-mapping work. Free
  to delete or accumulate; nothing else references this directory by
  file name.

## Promoting a run to a ref

If a probe produces data that ends up in `engine_api.md` (or that you
want to be the durable baseline for some future comparison), `git mv`
it from `runs/` to `refs/` and link it from the doc. Otherwise just
leave it in `runs/` — disk is cheap.
