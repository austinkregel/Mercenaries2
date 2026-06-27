local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

-- 1. Spawn VZ soldier using 7 arguments (just like MrxUtil.SpawnActor)
local ok, h = pcall(Pg.Spawn, "VZ", px + 3, py, pz + 3, yaw, false, true)
if not ok or not h then
    return "Spawn failed: " .. tostring(h)
end
log("Spawned actor (7 args): " .. tostring(h))

-- 2. Activate using _SpawnActorComplete
local complete_fn = _MODULES.mrxsupportdelivery.MrxUtil._SpawnActorComplete
local ok_comp, err_comp = pcall(complete_fn, h, "ActivatedSoldier7")
log(string.format("_SpawnActorComplete => ok=%s, err=%s", tostring(ok_comp), tostring(err_comp)))

-- 3. Check active humans list
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
    local status = "Activated soldier spawned successfully!"
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = status,
        nPriority = 1,
        nDuration = 5
    })
    
    -- Command to follow!
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
else
    log("Soldier still dormant or not registered in active list.")
end

return table.concat(r, "\n")
