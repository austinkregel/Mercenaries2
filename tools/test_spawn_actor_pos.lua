local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

local spawn_fn = _MODULES.mrxsupportdelivery.MrxUtil.SpawnActor
if type(spawn_fn) ~= "function" then
    return "SpawnActor function not found"
end

-- Pass position as a table {x, y, z}
local pos = { px + 5, py, pz + 5 }

local ok, h = pcall(spawn_fn, "VZ", "SpawnedVZ", pos, nil, yaw)
if ok and h then
    log(string.format("SpawnActor success! Handle=%s, Valid=%s, Alive=%s",
        tostring(h), tostring(Object.IsValid(h)), tostring(Object.IsAlive(h))))
else
    log("SpawnActor failed: " .. tostring(h))
end

return table.concat(r, "\n")
