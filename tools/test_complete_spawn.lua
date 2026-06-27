local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

-- 1. Spawn VZ soldier
local ok, h = pcall(Pg.Spawn, "VZ", px + 2, py, pz + 2, yaw)
if not ok or not h then
    return "Spawn failed: " .. tostring(h)
end
log("Spawned actor: " .. tostring(h))

-- 2. Call _SpawnActorComplete to run the full activation sequence
local complete_fn = _MODULES.mrxsupportdelivery.MrxUtil._SpawnActorComplete
if type(complete_fn) ~= "function" then
    return "_SpawnActorComplete not found"
end

local ok_comp, err_comp = pcall(complete_fn, h, "GroundSoldierComplete")
log(string.format("_SpawnActorComplete => ok=%s, err=%s", tostring(ok_comp), tostring(err_comp)))

-- 3. Check if they are now in the active list
local humans = Pg.FastCollectHumans()
local found = false
for _, human in ipairs(humans) do
    if human == h then
        found = true
        break
    end
end
log("Found in FastCollectHumans list: " .. tostring(found))

if found then
    local status = "VZ soldier spawned, activated, and tracked successfully!"
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = status,
        nPriority = 1,
        nDuration = 5
    })
    
    -- Command to follow player!
    local tArgs = {
        AIGuid = h,
        Role = "Follow",
        Target = lc,
        MinDistance = 2.0,
        MoveDistance = 4.0,
        MaxDistance = 50.0,
        Priority = "medPri"
    }
    pcall(Ai.Role, tArgs)
end

return table.concat(r, "\n")
