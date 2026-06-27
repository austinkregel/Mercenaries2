local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()

local spawn_fn = _MODULES.mrxsupportdelivery.MrxUtil.SpawnActor
if type(spawn_fn) ~= "function" then
    return "SpawnActor function not found"
end

local ok, h = pcall(spawn_fn, "VZ", "SpawnedVZ", lc)
if ok and h then
    log(string.format("SpawnActor success! Handle=%s, Valid=%s, Alive=%s",
        tostring(h), tostring(Object.IsValid(h)), tostring(Object.IsAlive(h))))
else
    log("SpawnActor failed: " .. tostring(h))
end

return table.concat(r, "\n")
