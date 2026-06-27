local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

local spawn_fn = _MODULES.mrxsupportdelivery.MrxUtil.SpawnActor
if type(spawn_fn) ~= "function" then
    return "SpawnActor function not found"
end

-- Spawn at the exact same height as the player (py), slightly offset by 1.5 meters on X/Z
local sx = px + 1.5
local sy = py
local sz = pz + 1.5

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))
log(string.format("Spawning at: %.2f, %.2f, %.2f", sx, sy, sz))

local ok, h = pcall(spawn_fn, "VZ", "GroundSoldier", { sx, sy, sz }, nil, yaw)
if ok and h then
    log(string.format("SpawnActor success! Handle=%s, Valid=%s, Alive=%s",
        tostring(h), tostring(Object.IsValid(h)), tostring(Object.IsAlive(h))))
    local hx, hy, hz = Object.GetPosition(h)
    log(string.format("Spawned Position: %.2f, %.2f, %.2f", hx, hy, hz))
else
    log("SpawnActor failed: " .. tostring(h))
end

return table.concat(r, "\n")
