-- Safe probe: only reads + type checks, no state mutation.
-- Confirms the high-value entry points are callable and what they
-- return so engine_api.md can move from "guessed" to "verified".

local results = {}

local function probe(label, fn)
  local ok, val = pcall(fn)
  if ok then
    table.insert(results, string.format("[OK] %s -> %s (%s)",
      label, tostring(val), type(val)))
  else
    table.insert(results, string.format("[ERR] %s -> %s", label, tostring(val)))
  end
end

local function probe_type(label, value)
  table.insert(results, string.format("[TYPE] %s = %s", label, type(value)))
end

-- ===== existence checks =====
probe_type("Player.GetLocalCharacter", Player.GetLocalCharacter)
probe_type("Player.GetLocalPlayer", Player.GetLocalPlayer)
probe_type("Player.GetCash", Player.GetCash)
probe_type("Player.GetFuel", Player.GetFuel)
probe_type("Object.GetPosition", Object.GetPosition)
probe_type("Object.GetHealth", Object.GetHealth)
probe_type("Object.GetName", Object.GetName)
probe_type("Sys.SetTimeScale", Sys.SetTimeScale)
probe_type("Sys.GetLevelName", Sys.GetLevelName)
probe_type("Sys.GetVersion", Sys.GetVersion)
probe_type("DebugTeleport", DebugTeleport)

-- ===== no-arg calls (capture signatures via error messages) =====
probe("Player.GetLocalPlayer()", function() return Player.GetLocalPlayer() end)
probe("Player.GetLocalCharacter()", function() return Player.GetLocalCharacter() end)
probe("Player.GetCash()", function() return Player.GetCash() end)
probe("Player.GetFuel()", function() return Player.GetFuel() end)
probe("Player.GetFuelCapacity()", function() return Player.GetFuelCapacity() end)
probe("Player.GetCurrentPlayers()", function() return Player.GetCurrentPlayers() end)
probe("Player.GetCurrentLocalPlayers()", function() return Player.GetCurrentLocalPlayers() end)
probe("Player.GetMaximumPlayers()", function() return Player.GetMaximumPlayers() end)
probe("Sys.GetLevelName()", function() return Sys.GetLevelName() end)
probe("Sys.GetVersion()", function() return Sys.GetVersion() end)
probe("Sys.GetPlatform()", function() return Sys.GetPlatform() end)
probe("Sys.GetLanguage()", function() return Sys.GetLanguage() end)
probe("Sys.GetMasterScriptName()", function() return Sys.GetMasterScriptName() end)
probe("Sys.MemUsage()", function() return Sys.MemUsage() end)
probe("Sys.RealTime()", function() return Sys.RealTime() end)
probe("Sys.MainTime()", function() return Sys.MainTime() end)
probe("Sys.IsLoadingOrStreaming()", function() return Sys.IsLoadingOrStreaming() end)
probe("Sys.HaveActiveProfile()", function() return Sys.HaveActiveProfile() end)
probe("Sys.IsDemoMode()", function() return Sys.IsDemoMode() end)
probe("Net.IsServer()", function() return Net.IsServer() end)
probe("Net.IsClient()", function() return Net.IsClient() end)
probe("Net.IsMultiplayer()", function() return Net.IsMultiplayer() end)
probe("Net.GetHostName()", function() return Net.GetHostName() end)
probe("Net.IsOnlineConnected()", function() return Net.IsOnlineConnected() end)

-- ===== chained: get player, then read its properties =====
local char = Player.GetLocalCharacter()
probe_type("Player.GetLocalCharacter() return", char)
if char then
  probe("Object.IsValid(char)", function() return Object.IsValid(char) end)
  probe("Object.IsAlive(char)", function() return Object.IsAlive(char) end)
  probe("Object.GetName(char)", function() return Object.GetName(char) end)
  probe("Object.GetLocalizedName(char)", function() return Object.GetLocalizedName(char) end)
  probe("Object.GetHealth(char)", function() return Object.GetHealth(char) end)
  probe("Object.GetMaxHealth(char)", function() return Object.GetMaxHealth(char) end)
  probe("Object.GetPosition(char)", function() return Object.GetPosition(char) end)
  probe("Object.GetYaw(char)", function() return Object.GetYaw(char) end)
  probe("Object.GetMass(char)", function() return Object.GetMass(char) end)
  probe("Object.GetVelocity(char)", function() return Object.GetVelocity(char) end)
  probe("Object.IsAwake(char)", function() return Object.IsAwake(char) end)
  probe("Object.InVehicle(char)", function() return Object.InVehicle(char) end)
  probe("Object.IsPlayerControlled(char)", function() return Object.IsPlayerControlled(char) end)
  probe("Object.GetModelName(char)", function() return Object.GetModelName(char) end)
end

-- ===== enumerate Disguise (1 entry — what is it?) =====
table.insert(results, "")
table.insert(results, "[ENUM] Disguise contents:")
for k, v in pairs(Disguise) do
  table.insert(results, string.format("  %s = %s", tostring(k), type(v)))
end

-- ===== enumerate FactionZone (1 entry) =====
table.insert(results, "[ENUM] FactionZone contents:")
for k, v in pairs(FactionZone) do
  table.insert(results, string.format("  %s = %s", tostring(k), type(v)))
end

-- ===== enumerate _SYS (6 entries) =====
table.insert(results, "[ENUM] _SYS contents:")
for k, v in pairs(_SYS) do
  table.insert(results, string.format("  %s = %s", tostring(k), type(v)))
end

return table.concat(results, "\n")
