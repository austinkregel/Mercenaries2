local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Current Player Position: %.2f, %.2f, %.2f", px, py, pz))

local spawn_fn = _MODULES.mrxsupportdelivery.MrxUtil.SpawnActor
if type(spawn_fn) ~= "function" then
    return "SpawnActor function not found"
end

-- Spawn directly at the player's exact coordinates
local ok, h = pcall(spawn_fn, "VZ", "ExactSpawnedVZ", { px, py, pz }, nil, yaw)
if ok and h then
    log(string.format("SpawnActor success! Handle=%s", tostring(h)))
    
    -- Teleport BOTH to the exact same spot
    log(string.format("Force-teleporting both to exact player coords: %.2f, %.2f, %.2f", px, py, pz))
    pcall(Object.SetPosition, h, px, py, pz)
    pcall(Object.SetPosition, lc, px, py, pz)
    
    local hx, hy, hz = Object.GetPosition(h)
    local nx, ny, nz = Object.GetPosition(lc)
    log(string.format("Actual spawned position: %.2f, %.2f, %.2f", hx, hy, hz))
    log(string.format("Actual player position: %.2f, %.2f, %.2f", nx, ny, nz))
else
    log("SpawnActor failed: " .. tostring(h))
end

return table.concat(r, "\n")
