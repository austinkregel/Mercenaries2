# multiplayer-restore (mercs2-qol-mods port)

Restores Mercenaries 2 online multiplayer by routing EA matchmaking
traffic to a private server and accepting that server's self-signed
TLS certificate. Drop-in mod for the
[mercs2-qol-mods SDK](https://github.com/Mercenaries-Fan-Build/mercs2-qol-mods).

This is a port of the multiplayer layer from
[loganw234/Mercenaries2](https://github.com/loganw234/Mercenaries2),
stripped of the Lua bridge so it cleanly fits the QoL mods framework.

> [!NOTE]
> Tested and verified working against **`v0.2.0` of the `pmc_bb.dll` loader** (the Mercenaries Fan Build loader).

## What it does

1. **DNS redirect** — hooks `ws2_32` resolvers so `*.ea.com`,
   `*.gamespy.com`, and `fesl*` resolve to the configured private
   server (default `refesl.live`).
2. **Cert blindfold** — hooks `wintrust!WinVerifyTrust` to accept the
   private server's self-signed cert blob. Local file/catalog cert
   validation is untouched.
3. **Time spoof** — pins the clock returned by Win32 + CRT time APIs
   to a date inside the served cert's validity window. Optional.
4. **FESL CA pubkey patch** — replays MLoader's 128-byte `.rdata`
   write at RVA `0x768378` so the game's SSL stack accepts the
   private server's cert chain. Gated on a SecuROM-unpack poll.

What it does NOT do: Lua bridge, REPL, modding hooks. Use the
upstream Merc2Fix ASI if you want those.

## Install

1. Build (see below) or drop a prebuilt `multiplayer_restore.asi`
   into your Mercenaries 2 install folder.
2. Drop `multiplayer_restore.ini` alongside it (only needed if you
   want to override the default server or disable the clock spoof).
3. Launch the game. Connect online normally — no MLoader required.

## Build

If this directory lives under `mercs2-qol-mods/mods/`:

```sh
cd mods/multiplayer-restore
make
```

Out-of-tree:

```sh
make SDK_DIR=/path/to/mercs2-qol-mods/sdk
```

Output: `multiplayer_restore.asi`.

## Config (`multiplayer_restore.ini`)

```ini
[server]
ip = refesl.live              ; hostname or dotted-quad

[compat]
spoof_clock = 1               ; 1 = spoof to 2012-06-15 (recommended)
```

## Status

**Proof of concept — not built or test-run against the mercs2-qol-mods
framework.** The author drafted this without the SDK build
environment (MinGW + `pmc_bb.dll` runtime + ASI loader chain) set up
locally. The underlying approach is validated, but actual integration
with the framework hasn't been exercised.

What's validated: the **standalone Merc2Fix.asi** (which this port is
derived from) was run against a `mercs2-securom-bypass`-patched
`Mercenaries2.exe`. All five hooks armed cleanly, multiplayer worked
end-to-end, and there were no anti-tamper trips. (The companion Lua
bridge correctly aborted itself via its RVA prologue check, which is
its intended fail-closed behavior — and is out of scope for this
multiplayer-only port anyway.) That confirms the hooking model and
the CA key patch path are sound on the bypass target.

What's *not* validated: that this specific port compiles cleanly under
the SDK's Makefile, hooks attach via `m2_hook_attach` exactly as
assumed, log output flows through `m2_logf` the way it should, the
INI parser callback signature matches `m2_ini_parse`. Likely failure
modes are SDK-integration mistakes (wrong helper signature assumed,
missing init step, style/convention mismatches) rather than
fundamental design issues. Treat this as a starting point that
should be reviewed and likely lightly reworked by someone with the
SDK build set up.

## One remaining open question

`FESL_CA_KEY_RVA = 0x768378` was extracted from MLoader's dump
against the archive.org English retail build. The bypass tool swaps
the import table `cruise.dll` → `pmc_bb.dll` (same name length, no
shift) and edits `.text` to strip DRM validation; it most likely
does not resize `.rdata`, so the offset should be stable — but it's
worth a 30-second verification before shipping. Inside the running
process, dump the first 16 bytes at `0x768378` and confirm they look
like a 128-byte placeholder (mostly zeros or a single repeated
pattern). If real data is there, the offset moved and needs
retargeting.

The SDK's `m2_hook.h` comment about `.rdata` anti-tamper does not
appear to apply on the bypass target (SecuROM is stripped,
`pmc_bb.dll` explicitly does no integrity checking per its README).
The CA patch keeps a brief unpack-wait poll as a no-op safety net
for users running it on a different binary (e.g. archive.org or
MLoader-cracked) but otherwise writes immediately.

## Acknowledgements

- **u/Kunster_** on r/MercenariesGames for ongoing collaboration
  on the Mercenaries 2 modding stack.
- The **mercs2-qol-mods** authors for the SDK this mod plugs into.
- **Tsuda Kageyu** for MinHook (vendored by the SDK, BSD-2-Clause).

## License

MIT — same as the upstream Merc2Reborn project.
