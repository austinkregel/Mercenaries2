# Mercenaries 2 — Engine Lua API Reference

Discovered via runtime walk of `_G` and reachable sub-tables on 2026-06-26
using `tools/walk_globals.lua` (full dump: `out/globals_ingame.txt`,
8415 entries total). This file lists the engine-side functions
(everything under named top-level namespaces — i.e. NOT `_MODULES`,
which is game-script code).

Signatures are **inferred from names** unless explicitly marked
**verified**. Test methodology at the bottom.

---

## Quick reference: cheats and modder essentials

### Player economy
| Call | Likely effect |
|------|---------------|
| `Player.GetCash()` | current cash balance |
| `Player.AddCash(n)` | add n cash |
| `Player.SetCash(n)` | force cash to n |
| `Player.GetFuel()` / `SetFuel(n)` / `AddFuel(n)` | fuel (used for support / airstrikes) |
| `Player.GetFuelCapacity()` / `SetFuelCapacity(n)` | fuel cap |

### Player invincibility / state
| Call | Likely effect |
|------|---------------|
| `Player.GetLocalCharacter()` | returns the local player's character object — most setters below take this |
| `Object.SetInvincible(char, true)` | god mode (no damage taken) |
| `Object.SetUnkillable(char, true)` | can't die (different from invincible — survives lethal hits) |
| `Object.SetInfiniteAmmo(char, true)` | infinite ammo |
| `Object.SetHealth(char, n)` | force health |
| `Object.Revive(char)` | resurrect |
| `Player.SetGrappleEnabled(true)` | toggle grapple |
| `Player.SetScopeEnabled(true)` | toggle scope |
| `Player.SetHealthClamp(min, max)` | min/max HP bounds |

### Teleport
| Call | Likely effect |
|------|---------------|
| `Object.GetPosition(obj)` | get xyz of any object |
| `Object.SetPosition(obj, x, y, z)` | teleport object |
| `Object.SetYaw(obj, deg)` | rotate |
| `Player.TeleportCamera(...)` | move camera |
| `Player.SetPlayerStart(...)` | set the per-player respawn / start point |
| `DebugTeleport(...)` | top-level debug teleport — signature unknown, worth probing |

### Time / game flow
| Call | Likely effect |
|------|---------------|
| `Sys.SetTimeScale(n)` | **slow-mo / fast-forward** (1.0 = normal, 0.5 = half speed, 2.0 = double) |
| `Sys.SetSkipMission(true)` / `GetSkipMission()` | the "Skip to a mission" cheat backing |
| `Sys.PlayIntroMovies()` | replay intro |
| `Sys.ForceNextAutosave()` | autosave on demand |
| `Sys.RequestAutosave()` | request (may defer) |
| `Sys.SetAutosaveEnabled(bool)` | toggle autosave |
| `Sys.RequestGameState(...)` | game state transitions |
| `Sys.SetTutorialsEnabled(false)` | disable tutorial popups |
| `Sys.NoHud(true)` | hide HUD entirely |

### Weapons / ammo
| Call | Likely effect |
|------|---------------|
| `Weapon.GetClipAmmo(weapon)` / `SetClipAmmo(weapon, n)` | current clip |
| `Weapon.GetReserveAmmo(weapon)` / `SetReserveAmmo(weapon, n)` | reserve |
| `Weapon.Reload(weapon)` | force reload |
| `Weapon.IsDesignator(weapon)` | laser designator check (used for airstrikes) |
| `Airstrike.EquipDesignator(player)` | give designator |
| `Airstrike.RefillDesignator(player)` | replenish marker shots |

### Airstrikes / spawning ordnance
| Call | Likely effect |
|------|---------------|
| `Airstrike.SpawnOrdnance(...)` | drop a bomb |
| `Airstrike.SpawnTargettedOrdnance(...)` | guided ordnance |
| `Airstrike.SpawnPlaneNew(...)` | spawn a strike plane |
| `Airstrike.SpawnDirectedObject(...)` | directional spawn |
| `Airstrike.SpawnCarpetBombLine(...)` | carpet bomb |
| `Airstrike.Flyby(...)` | recon-style flyover |
| `Airstrike.ConeSpawn(...)` | cone-shaped spawn pattern |

### Vehicles
| Call | Likely effect |
|------|---------------|
| `Vehicle.Enter(player, vehicle, seat?)` | force-enter a vehicle |
| `Vehicle.Exit(player)` | exit |
| `Vehicle.RestoreHealth(vehicle)` | repair |
| `Vehicle.RestoreAmmo(vehicle)` | restock turrets |
| `Vehicle.SetTurretPitch(v, deg)` / `SetTurretYaw(v, deg)` | aim turret |
| `Vehicle.IsFlipped(v)` / `IsFlying(v)` | state checks |
| `Vehicle.SetParts(v, ...)` | swap parts (mod potential!) |
| `Vehicle.SpinHeli(v, ...)` | helicopter rotor effect |

### Cinematics / movies
| Call | Likely effect |
|------|---------------|
| `Movie.Start(name)` / `Pause()` / `Resume()` / `Stop()` | cutscene control |
| `Player.SetCinematicMode(true)` | enter cinematic camera |
| `Player.InCinematicMode()` | query |
| `Camera.Blend(...)` | smooth camera transition |
| `Camera.Follow(target)` | follow object |
| `Camera.SetShot(...)` | named shot |
| `Camera.Shake(...)` | screen shake |
| `Camera.SetFOV(deg)` / `GetFOV()` | field of view |
| `Net.SendEvent_HideMovie()` / `ShowMovie(...)` | UI movie overlay |

### Cheat menu / debug
| Call | Likely effect |
|------|---------------|
| `Cheat.DisplayOptions()` | **the dev cheat menu** (verified working) |
| `Debug.Printf(fmt, ...)` | script-side logging (where it ends up TBD) |
| `Debug.LogError/Warning/Info(msg)` | tiered logging |
| `Debug.GetCallstack()` | grab current Lua call stack |
| `Debug.Assert(cond, msg)` | assert |

### Multiplayer / network
| Call | Likely effect |
|------|---------------|
| `Net.IsServer()` / `IsClient()` / `IsMultiplayer()` | role checks |
| `Net.GetHostName()` | host info |
| `Net.GrantAchievement(player, id)` | unlock achievement |
| `Net.KickPlayer(player)` | kick |
| `Net.QuitGame()` | host quit |
| `Net.UpdatePresence(...)` | rich presence update |
| `Net.ConnectToServer(addr)` | client connect |
| `Net.SendCustomEvent(...)` | generic event broadcast — **interesting for mods** |
| `Net.SendEvent_*` (32+ variants) | typed events (objectives, fanfare, teleport, dangerous-building, etc.) |

### PDA (in-game menu / map)
| Call | Likely effect |
|------|---------------|
| `Pda.Map.AddMission(...)` | add custom mission marker |
| `Pda.Map.AddBlip(...)` | add map blip |
| `Pda.Map.SetSelectedMission(...)` | force select |
| `Pda.Database.AddDossierEntry(...)` | add to in-game dossier |
| `Pda.Database.AddHelpEntry(...)` | add help text |
| `Pda.Database.SetFactionAttitude(faction, value)` | faction attitude |
| `Pda.SetSuppressed(bool)` | hide/show the PDA |

### AI / faction
| Call | Likely effect |
|------|---------------|
| `Ai.SetAttitude(target, attitude)` | per-target hostility |
| `Ai.SetRelation(...)` / `GetRelation(...)` | faction relationships |
| `Ai.ChangeRelation(...)` | tweak |
| `Ai.SetFacing(npc, deg)` | rotate NPC |
| `Ai.HeliLand(heli)` / `HeliTakeoff(heli)` | helicopter scripted actions |
| `Ai.HeliDropZoneInfo(...)` | drop zone setup |
| `Ai.Goal(npc, goal)` | task an NPC |
| `Ai.Plan(...)` / `PlanIterate(...)` / `PlanClear(...)` | AI planning |
| `Ai.Squad(...)` | squad management |

### Disguise (faction camouflage)
| Call | Likely effect |
|------|---------------|
| `Player.GetVehicleDisguise()` / `SetVehicleDisguise(...)` | per-vehicle disguise |
| `Player.GetVehicleDisguiseState()` / `VehicleDisguise(...)` | state |
| `Disguise` namespace | (table — only 1 entry, worth probing) |

### Camera (free camera potential)
| Call | Likely effect |
|------|---------------|
| `Camera.SetPosition(x, y, z)` | place camera |
| `Camera.SetLookAt(x, y, z)` | look-at |
| `Camera.SetPitch(deg)` / `SetYaw(deg)` | rotate |
| `Camera.Hold(...)` | hold position |
| `Camera.SetShot(name)` | named shot |
| `Camera.Blend(...)` | transition |

### Graphics
| Call | Likely effect |
|------|---------------|
| `Graphics.SetGamma(n)` | gamma adjust |
| `Graphics.ScreenShot()` | take screenshot |
| `Graphics.SetShadowBaseDistance(n)` | shadow LOD |
| `Graphics.ReloadShaders()` | hot-reload shaders (modder gold) |
| `Graphics.GetScreenRatio()` / `SetScreenRatio(n)` | aspect ratio |

### Module loading
| Call | Likely effect |
|------|---------------|
| `import(name)` | load a Lua module by name |
| `dynamic_import(name)` | runtime module load |
| `dynamic_remove(name)` | unload |
| `inherit(class, parent)` | OOP helper |

---

## Per-namespace coverage

Counts are total entries (functions + sub-tables + constants) per
namespace. See `out/globals_ingame.txt` for the full list.

| Namespace | Entries | Notes |
|-----------|---------|-------|
| `_MODULES` | 6837 | Game-script-defined modules — mission scripts, AI logic, etc. Worth grepping for specific behaviors (e.g. `grep "_MODULES\.mrxbriefing"` for briefing logic). |
| `_GuiInternal` | 115 | Engine-side Flash UI bridge. `RemoveFlashPauseMenu` / `SetFlashPauseMenu` here. |
| `Player` | 107 | Player state, cash/fuel, costumes, profile, boundary control. |
| `Hud` | 100 | All in sub-tables: `Announcement`, `CardFanfare`, `Cinematic`, `ClassyText`, `ContactFanfare`, `EventFanfare`, `FactionDisplay`, `Fanfare`, `FanfareQueue`, `SupportMenu`, etc. |
| `Net` | 92 | Multiplayer + typed event broadcast. |
| `Sound` | 88 | Music cues, source playlists, faction music, fade categories. Very granular. |
| `Object` | 87 | Generic entity manipulation — used by both Player and Vehicle objects. |
| `Graphics` | 85 | Shadows, gamma, shaders, screenshots. |
| `Pg` | 80 | Unknown — worth a `Pg` deep dive to figure out what "Pg" stands for. |
| `Ai` | 66 | NPC behavior, factions, attitudes, plans, spawn lists. |
| `Sys` | 64 | Game flow, time scale, level loading, save management. |
| `LTILibName` | 52 | Unknown — worth probing. |
| `MessageBox` | 48 | In-game message box dialogs. |
| `Event` | 48 | Event constants (mostly `number` typed — script-side event IDs). |
| `SubtitleBuffer` | 47 | Subtitle rendering. |
| `Vehicle` | 40 | Vehicle interaction. |
| `Gui` | 38 | High-level GUI. |
| `Pda` | 36 | PDA / map / database. |
| `MapLabel` | 35 | Map text labels. |
| `Human` | 31 | Human character control. |
| `Controller` | 25 | Input / gamepad. |
| `Junk` | 24 | Probably destructibles / props. |
| `VO` | 17 | Voice-over playback. |
| `ObjectiveTray` | 17 | Objective UI elements. |
| `Math` | 17 | Math helpers (game-specific, not Lua's standard math). |
| `Camera` | 14 | Camera control. |
| `Marker` | 13 | World markers. |
| `Airstrike` | 12 | Support strikes / aerial spawning. |
| `Weapon` | 9 | Ammo / reload. |
| `ObjectState` | 9 | State machines. |
| `Animation` | 6 | Animation control. |
| `Debug` | 6 | Logging + callstack. |
| `_SYS` | 6 | Engine-internal. |
| `Report` | 5 | Reports / stats. |
| `Movie` | 4 | Cutscene control. |
| `FactionZone` | 1 | One entry — probably a constants table. |
| `Disguise` | 1 | One entry — probe what's in it. |
| `Cheat` | 1 | `Cheat.DisplayOptions` — that's the whole namespace. |

---

## VERIFIED — `Player.*` reference (2026-06-26)

Probed against in-HQ state on level `"vz"`. Where a function exists in both
`Player.X()` and `Player.X(playerHandle)` forms, the no-arg form
defaults to the **local primary player**.

### Player handles
The engine assigns `userdata` handles for players and characters.
Observed pattern (high-bit looks like a kind tag):

| Handle | What it is |
|--------|-----------|
| `userdata: 40000014` | Primary local player object |
| `userdata: 40000015` | Secondary local player (exists in SP — for split-screen co-op slot) |
| `userdata: 4000563D` | Primary character (different handle from player) |
| `userdata: F0000000` | "Any character" sentinel returned by `GetAnyCharacter()` |
| `userdata: 80000003` | Returned as `Object.GetParent(character)` — probably scene root |

### Identity / lookup
| Signature | Verified return |
|-----------|----------------|
| `Player.GetLocalPlayer() -> player` | userdata player handle |
| `Player.GetLocalCharacter() -> character` | userdata character handle |
| `Player.GetPrimaryPlayer() -> player` | same as GetLocalPlayer in SP |
| `Player.GetPrimaryCharacter() -> character` | same as GetLocalCharacter in SP |
| `Player.GetSecondaryPlayer() -> player` | exists in SP (handle 40000015) |
| `Player.GetSecondaryCharacter() -> nil` | nil in SP (no second character spawned) |
| `Player.GetAnyCharacter() -> sentinel` | returns `F0000000` regardless |
| `Player.GetAllPlayers() -> table` | array table; SP returns 1 entry |
| `Player.GetAllCharacters() -> userdata` | returns a userdata handle (NOT a table — probably an iterator) |
| `Player.GetCharacter(player) -> character` | character belonging to that player |
| `Player.GetName(player) -> string` | e.g. `"player0"` |
| `Player.GetPlayerId(player) -> number` | small int (0 for primary) |
| `Player.IsLocal(player) -> bool` | true for local players |
| `Player.IsCoopMultiplayer() -> bool` | true in co-op |

### Player state (no args = local player)
| Signature | Verified |
|-----------|----------|
| `Player.GetCash() -> number` | `1141700` |
| `Player.GetFuel() -> number` | `300` |
| `Player.GetFuelCapacity() -> number` | `300` |
| `Player.GetCurrentPlayers() -> number` | `1` |
| `Player.GetMaximumPlayers() -> number` | `2` (split-screen cap) |
| `Player.GetCurrentLocalPlayers()` / `GetMaximumLocalPlayers()` | same as above in SP |
| `Player.GetCameraXZHeading(player) -> radians` | `4.35` (= 249°) |
| `Player.GetControlBindingType(player) -> string` | `"human"` (vs presumably "vehicle") |
| `Player.GetPlayerStart(player) -> string` | spawn marker name e.g. `"PlayerLocation_Start"` |
| `Player.GetRetryPosition(player) -> x, y, z` | 3-number return |
| `Player.GetTargetUnderReticle(player) -> x, y, z, object` | 4-value return — position + the object you're looking at |
| `Player.GetViewport(player) -> w, h, x, y, n` | 5 numbers: `2560, 1440, 0, 0, 1` (screen w/h/x/y/?) |
| `Player.GetViewportId(player) -> userdata` | viewport handle |
| `Player.GetCamera(player) -> userdata` | camera object |
| `Player.GetControlledObject(player) -> character` | == GetLocalCharacter in normal play; would be vehicle when driving |
| `Player.GetProfileCharacter(player) -> number` | character template ID (1 = Mattias?) |
| `Player.GetProfileCostume(player) -> number` | outfit ID |
| `Player.GetAvailableCostumes(player) -> number` | count of unlocked outfits |
| `Player.GetVehicleDisguise(player) -> bool` | true when disguised (faction-neutral in HQ) |

### Returns nil when not applicable
- `GetSeat(player)` → nil when on foot
- `GetLocalId(player)` → nil in SP
- `GetVehicleDisguiseState(player)` → void (0 returns) when no active disguise change
- `IsJoined`, `IsRemote`, `IsBoundaryDeath` → nil in normal SP

---

## VERIFIED — `Object.*` reference (against local character)

The Object namespace is a generic API that works on any engine entity
(character, vehicle, prop). All `Object.X(obj, ...)` calls take the
object handle as first arg.

### Identity / state predicates
| Signature | Verified for character in HQ |
|-----------|-------------------------------|
| `Object.IsValid(obj) -> bool` | true |
| `Object.IsAlive(obj) -> bool` | true |
| `Object.IsAwake(obj) -> bool` | true (physics active) |
| `Object.IsTemplate(obj) -> bool` | false (real entity, not a template) |
| `Object.IsVisible(obj) -> bool` | true |
| `Object.IsDisguised(obj) -> bool` | false (HQ disguise is on player, not character) |
| `Object.IsHibernated(obj) -> bool` | false (LOD active) |
| `Object.IsAttached(obj) -> bool` | false |
| `Object.IsPlayerControlled(obj) -> player_handle\|nil` | **returns the controlling player handle, not just `true`** — `40000014` in our test |
| `Object.HasWinch(obj) -> bool` | false |
| `Object.IsWinched(obj)` / `IsWinching(obj)` | nil for non-winch objects |
| `Object.InVehicle(obj) -> vehicle?, seat?` | 2-tuple — both nil when on foot, likely `(vehicleHandle, seatIdx)` when in a vehicle |
| `Object.InSeat(obj)` | nil when on foot |
| `Object.InsideBoundary(obj)` / `OutsideBoundary(obj)` | nil — probably need a boundary GUID arg |
| `Object.HasLabel(obj, str) -> bool` | tested `"player"` → false (need to discover real labels) |

### Names
| Signature | Verified |
|-----------|----------|
| `Object.GetName(obj) -> string\|nil` | nil for player character |
| `Object.GetLocalizedName(obj) -> string` | `"[0xb7f587a3]"` — that's a hash, not a name. There's likely a localization string table we haven't found. |
| `Object.GetModelName(obj) -> userdata` | returns a hash handle, not a string. Pipe through `Sys.GuidToString(handle)`? |

### Health / damage
| Signature | Verified |
|-----------|----------|
| `Object.GetHealth(obj) -> number` | `120` |
| `Object.GetMaxHealth(obj) -> number` | `120` |
| `Object.GetInvincible(obj) -> bool` | `true` (HQ removes weapons so engine makes you invincible) |
| `Object.GetNodeHealth(obj)` | nil for character — probably needs a node index arg |

### Spatial
| Signature | Verified |
|-----------|----------|
| `Object.GetPosition(obj) -> x, y, z` | **3-tuple**: `(3789.29, 450.07, -3881.22)` |
| `Object.GetYaw(obj) -> radians` | `3.997` (= 229°) |
| `Object.GetVelocity(obj) -> number` | scalar magnitude |
| `Object.GetVelocitySquared(obj) -> number` | magnitude² (skip sqrt for distance compares) |
| `Object.GetVelocityVector(obj) -> vx, vy, vz` | **3-tuple** |
| `Object.GetHeightAboveTerrain(obj) -> number` | `111.58` (m above ground, regardless of absolute Y) |
| `Object.GetMass(obj) -> number` | `100` (kg presumed) |
| `Object.GetHibernationDistance(obj) -> number` | `120` (distance beyond which object hibernates / LOD) |
| `Object.GetPhysicsType(obj) -> string` | `"human"` (other values likely `"vehicle"`, `"prop"`, etc.) |

### Hierarchy / attachments
| Signature | Verified |
|-----------|----------|
| `Object.GetParent(obj) -> userdata` | `80000003` (scene root for top-level objects) |
| `Object.GetAttachedObjects(obj) -> table` | **array of attached entities** — character had 4 attached (weapons/accessories): `{40005760, 4000575F, 4000575D, 4000575B}` |
| `Object.GetWinchState(obj)` | nil for non-winch |

### Hardpoints (vehicle turrets / mount points)
| Signature | Verified |
|-----------|----------|
| `Object.GetHardpointPosition(obj)` | nil for character — likely needs a hardpoint name/idx arg, and only valid on vehicles with mounts |
| `Object.GetHardpointPitch(obj)` / `GetHardpointYaw(obj)` | nil for character |

### Misc
- `Object.GetCashValue(obj)` returns void (0 values) for characters — likely returns the cash drop value for collectable objects.

### Mutator pattern (verified with `Player.AddCash`)

`Player.AddCash(n)` returns nothing (`pcall` returned 0 values), but
mutates cash by exactly `n`. Negative values work — they subtract.

```lua
local before = Player.GetCash()    -- 1141700
Player.AddCash(1)                  -- (void return)
Player.GetCash()                   -- 1141701  (+1 delta confirmed)
Player.AddCash(-1)                 -- (void return)
Player.GetCash()                   -- 1141700  (exact revert)
```

Generalisable convention for the rest of the API: `Add*` mutators
take a signed delta, return void; `Set*` mutators take an absolute
value, return void; `Get*` are the readers. Always read-then-write
when developing a mod so you can revert.

### Attached objects = equipment slots (verified)

`Object.GetAttachedObjects(character)` returns the character's
**equipment loadout** as a numbered table. In our test the character
had 4 slots:

| Slot | Handle | `IsPrimary` | Clip / Max | Reserve | Health | Guess |
|------|--------|-------------|------------|---------|--------|-------|
| 1 | `4000575B` | true | 100/100 | 6 | 100/100 | primary rifle |
| 2 | `4000575D` | true | 75/75 | 6 | 100/100 | secondary firearm |
| 3 | `4000575F` | false | n/a | 4 | nil | grenade type 1 |
| 4 | `40005760` | false | n/a | 5 | nil | grenade type 2 |

All slots have `Object.GetPhysicsType(slot) == "prop"` — the engine's
weapon entities are just specialised props. Both `Object.*` and
`Weapon.*` calls work on them (they share the same underlying handle).
`nil` returns from `GetClipAmmo` / `GetHealth` on slots 3-4 indicate
the property doesn't apply to that weapon class (grenades have no
magazine, no per-grenade health).

### Multi-return gotcha
**Many `Object.Get*` functions return tuples** (position = 3 values, velocity = 3 values, target-under-reticle = 4 values, viewport = 5 values). To capture all of them in Lua:

```lua
local x, y, z = Object.GetPosition(obj)
-- NOT:
local pos = Object.GetPosition(obj)  -- only catches x
```

When wrapped in `pcall`:

```lua
local function multi(ok, ...) return ok, {...} end
local ok, vals = multi(pcall(Object.GetPosition, obj))
-- vals = {x, y, z}
```

---

## VERIFIED — Vehicle & Seat reference

Interaction with vehicles and seat occupancy. Seat handles are distinct from vehicle handles.

| Signature | Verified behavior |
|-----------|-------------------|
| `Object.InVehicle(character) -> vehicle?, seat?` | Returns vehicle handle and seat handle if inside a vehicle, else nil |
| `Vehicle.GetFromRider(character) -> seat_handle?` | Returns seat handle character is occupying, else nil |
| `Vehicle.GetSeatFromRider(character) -> vehicle_handle?` | Returns vehicle handle character is riding, else nil |
| `Vehicle.GetRiderFromSeat(vehicle, seat) -> character?` | Returns character handle occupying the seat, else nil |
| `Vehicle.GetSeatParams(vehicle, seat) -> table` | Returns seat properties table: `IsHijackBlocker`, `IsDriver`, `IsCargo`, `IsGunner`, `IsRiderVulnerable`, `IsStowable`, `IsRiderBashable`, `IsHijackable`, `StowSeatGuid`, `IsRiderInvisible` |

---

## VERIFIED — Ai & Factions reference

Faction GUIDs can be looked up via `_MODULES.vz.MrxFactionManager._tFactions.[FactionName].uGuid`.
Attitude levels are: `1` = Hostile, `2` = Neutral, `3` = Friendly.
Relations range from `-100` (hostile) to `100` (friendly).

| Signature | Verified behavior |
|-----------|-------------------|
| `Ai.GetRelation(subjectGuid, objectGuid) -> number` | Returns the relation value between two faction GUIDs or character handles |
| `Ai.SetRelation(subjectGuid, objectGuid, value)` | Sets the absolute relation value between two faction GUIDs |
| `Ai.ChangeRelation(subjectGuid, objectGuid, delta)` | Modifies relation value between two faction GUIDs by signed delta |
| `Ai.SetAttitude(subjectGuid, objectGuid, level)` | Sets the attitude level (1, 2, or 3) between two faction GUIDs |
| `Ai.Role(tArgs) -> number` | Commands an AI NPC to perform a behavior role (returns `1` on success). |

#### `Ai.Role(tArgs)` keys:
- `AIGuid` (userdata): NPC character handle to command.
- `Role` (string): Behavior role to assign. Verified values:
  - `"Follow"`: Follow a target entity.
  - `"Passenger"`: Command to ride as passenger in a vehicle.
- `Target` (userdata): Target entity to follow or interact with (e.g. the player character handle).
- `MinDistance` (number): Minimum distance to maintain from target (e.g. `2.0`).
- `MoveDistance` (number): Distance threshold beyond which the NPC begins moving (e.g. `4.0`).
- `MaxDistance` (number): Maximum distance threshold before the command is lost or aborted (e.g. `50.0`).
- `Priority` (string): Execution priority. Typically `"medPri"`.

---

### Spawning & Activation
Spawning live characters requires using 7 arguments with `Pg.Spawn` to activate the entity, followed by a specific initialization order to enable their AI and hand control over to the animation engine.

| Signature | Verified behavior |
|-----------|-------------------|
| `Pg.Spawn(sTemplate, x, y, z, yaw, bInanimate, bActive) -> handle` | Spawns an entity in the world. Passing `false` for `bInanimate` and `true` for `bActive` spawns the actor as active (not dormant). |
| `Ai.Enable(actor, bDisable)` | Activates the AI behavior when `bDisable` is `false`. |
| `Object.DisablePhysics(actor)` | Disables raw physics simulation, handing motion control to the animation engine. |

#### Spawning Constraints & Guidelines:
1. **Memory Streaming**: The template name passed to `Pg.Spawn` MUST be loaded in the level's active sector memory to render visibly. If you spawn an out-of-sector template (like spawning VZ soldiers inside the PMC HQ), they will spawn invisibly because their model/texture assets are unloaded.
2. **Faction templates**:
   - `"PMC"`: PMC soldier (loaded at PMC HQ)
   - `"OC"`: Oil / UP soldier (loaded at PMC HQ)
   - `"VZ"`: Venezuelan soldier (loaded in VZ sectors)
3. **Correct Initialization Sequence**:
   ```lua
   -- 1. Spawn directly at active coordinates
   local h = Pg.Spawn("PMC", px + 2, py, pz + 2, yaw, false, true)
   
   -- 2. Prevent garbage collection
   _G.MySpawnedActor = h
   
   -- 3. Teleport to navmesh node and orient
   Object.SetPosition(h, px + 2, py, pz + 2)
   Object.SetYaw(h, yaw)
   
   -- 4. Enable AI and hand over to animation engine
   Ai.Enable(h, false)
   Object.DisablePhysics(h)
   ```

4. **Squad Spawning via Vehicles (Recommended/Stable)**:
   Spawning individual human actors directly can be restricted by dynamic streaming sector cleanses. The most stable way to spawn a squad is to spawn a crewed transport vehicle, extract the riders, and command them.
   ```lua
   -- Spawn transport helicopter containing full faction crew
   local heli = Pg.Spawn("UH1 Transport (GR) (Full)", px + 10, py, pz + 10, yaw, false, true)
   _G.MySquadHeli = heli
   
   -- Extract riders, make them friendly, and command to follow
   local riders = Vehicle.GetRiders(heli)
   for seat, rider in pairs(riders) do
       _G["SquadRider_" .. seat] = rider
       Object.SetPosition(rider, px + 2, py, pz + 2) -- eject/teleport to player ground
       Ai.SetAttitude(rider, Player.GetLocalCharacter(), 3)
       Ai.SetAttitude(Player.GetLocalCharacter(), rider, 3)
       Ai.Role({
           AIGuid = rider,
           Role = "Follow",
           Target = Player.GetLocalCharacter(),
           MinDistance = 2.0,
           MoveDistance = 4.0,
           MaxDistance = 50.0,
           Priority = "medPri"
       })
   end
   ```

### NPC Introspection & Tracking
To scan, track, and retrieve info from NPCs currently loaded in the world, use `Pg.FastCollectHumans`.

| Signature | Verified behavior |
|-----------|-------------------|
| `Pg.FastCollectHumans() -> table` | Returns an array table of all loaded human handles in the region (including the player character). |
| `Object.GetHealth(obj) -> number` | Returns the current health value (e.g. `120` for player, `125` for Oil, `40` for VZ). |
| `Object.GetMaxHealth(obj) -> number` | Returns the maximum health value. |
| `Ai.GetFactionGuid(char) -> factionGuid` | Returns the faction identifier handle of a character. |
| `Object.InVehicle(obj) -> vehicleHandle?, seatHandle?` | Returns vehicle and seat handles if inside a vehicle, else `nil`. |
| `Object.SetPosition(obj, x, y, z)` | Instantly teleports the entity (player or NPC) to absolute coordinates. |

---

## VERIFIED — Pda reference

Method calls on Pda namespaces must be invoked with colon syntax (e.g. `Pda.Database:AddHelpEntry(tArgs)`).

### Pda.Database
- `Pda.Database:AddHelpEntry(tArgs)`
  - `tArgs` keys: `sTitle` (string), `sText` (string), `sIcon` (string, optional), `vPlayer` (player handle, optional)
- `Pda.Database:AddLogEntry(tArgs)`
  - `tArgs` keys: `sType` (string), `sName` (string), `sMessage` (string), `sColor` (string, optional), `vPlayer` (player handle, optional)
- `Pda.Database:AddDossierEntry(tArgs)`
  - `tArgs` keys: `sTitle` (string), `sText` (string), `sIcon` (string, optional), `vPlayer` (player handle, optional)

### Pda.Map
- `Pda.Map:AddBlip(tArgs)`
  - `tArgs` keys: `sName` (string), `sLabel` (string), `sDesc` (string), `uGuid` (object handle/GUID), `sTexture` (string), `bSticky` (boolean, optional), `vPlayer` (player handle, optional), `bTodoList` (boolean, optional), `sFaction` (string, optional), `nSortOrder` (number, optional), `bDontNetSync` (boolean, optional)
- `Pda.Map:AddMission(tArgs)`
  - `tArgs` keys: `sName` (string), `sLabel` (string), `sDesc` (string), `sFaction` (string), `sDefaultBlipTexture` (string), `sDefaultBlipLabel` (string), `bSuppress` (boolean, optional), `bTrackable` (boolean, optional), `nSortOrder` (number, optional), `vPlayer` (player handle, optional)

---

## VERIFIED — Hud reference

Method calls on Hud namespaces must be invoked with colon syntax (e.g. `Hud.ClassyText:ShowText(tArgs)`).

### Hud.ClassyText
- `Hud.ClassyText:ShowText(tArgs)`
  - `tArgs` keys: `sText` (string/hash), `nDuration` (number)
  - Displays clean styled text centered on screen.

### Hud.TextFanfare
- `Hud.TextFanfare:Commence(tArgs)`
  - `tArgs` keys: `sLine1` (string), `sLine2` (string), `nEntranceTime` (number), `nDisplayTime` (number), `nFadeTime` (number)
  - Displays large sliding title (uses currency font, sliding from left/right).

### Hud.MessageBox
- `Hud.MessageBox:AddMessage(tArgs)`
  - `tArgs` keys: `vPlayer` (player handle), `sMessage` (string), `nPriority` (number), `nDuration` (number), `nFadeTime` (number, optional), `bClearBuffer` (boolean, optional), `bAllowsAppends` (boolean, optional)
  - Displays messages in log feed at the top of the screen.

### Hud.Announcement
- `Hud.Announcement:Show(tArgs)`
  - `tArgs` keys: `vPlayer` (player handle), `sTexture` (string), `nDuration` (number), `nWidth` (number, optional), `nHeight` (number, optional), `sHorizontalAnchor` (string, optional), `sVerticalAnchor` (string, optional), `vSoundEffect` (optional)
  - Displays a large icon/announcement layout at the bottom of the screen.

### Hud.ResourceCounter
- `Hud.ResourceCounter:SetCash(tArgs)`
  - `tArgs` keys: `vPlayer` (player handle), `nValue` (number), `sReason` (string, optional), `nIncrement` (number, optional)
  - Sets the cash value display and reason in the cash HUD element.
- `Hud.ResourceCounter:Show(tArgs)`
  - `tArgs` keys: `vPlayer` (player handle), `nDuration` (number)
  - Forces the cash counter to show on screen.

### Hud.ObjectiveTray
- `Hud.ObjectiveTray:SetSlotToText(tArgs)`
  - `tArgs` keys: `vPlayer` (player handle), `nSlot` (number, index), `sText` (string), `bDontNetSync` (boolean, optional)
  - Displays persistent objective text in the specified slot index.

---

## VERIFIED — Localization reference

The game handles localized text strings transparently. Pass localized name hash strings like `"[0xb7f587a3]"` directly to engine UI / display functions (e.g., `Hud.ClassyText:ShowText`) to render their translated string in-game.

| Signature | Verified behavior |
|-----------|-------------------|
| `Sys.GuidToString(guidHandle) -> string` | Converts a userdata GUID/model handle to its hex string representation (e.g., `"0xA3C1FABC"`) |

## How to verify a function

Stock Lua introspection is unavailable (`debug` lib is stripped). Test
empirically — pcall catches errors:

```lua
-- 1. Confirm it exists and is callable
local fn = Player.AddCash
return type(fn) == "function" and "yes" or "no"

-- 2. Try with no args — error message often reveals expected signature
local ok, err = pcall(Player.AddCash)
return tostring(ok) .. " : " .. tostring(err)

-- 3. Try with a small/safe value
local before = Player.GetCash()
Player.AddCash(1)
local after = Player.GetCash()
return string.format("before=%s after=%s", tostring(before), tostring(after))
```

Run via `py tools/lua_repl.py < your_test.lua`. The bridge prints
`[ok]` / `[runtime]` (label is cosmetic — see
[project-lua-bridge memory](../../.claude/projects/...) — junk at slot
0, real return at slot 1+).

Once a function is verified, update this doc with the confirmed
signature and a working call example.

---

## What's missing from this list

- **`_MODULES` introspection** — 6837 game-script entries. Useful for
  finding specific mission/behavior implementations but too noisy to
  list here. Grep `out/globals_ingame.txt` for specific patterns.
- **Sub-table contents** of namespaces like `Hud.*` (subtables only —
  needs another walk one level deeper at those addresses).
- **Function signatures** — all inferred from names. The "signature
  unknowns" section above is the priority list.
- **Constants** — 1040 number-typed entries and 234 string-typed
  entries are likely enums / event IDs / asset paths. Worth dumping
  separately if any specific call needs a magic value.
