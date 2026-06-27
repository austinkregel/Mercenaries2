local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

-- Spawn OC (Oil) soldier directly at player position with 7 args
local ok, h = pcall(Pg.Spawn, "OC", px + 2, py, pz + 2, yaw, false, true)
if ok and h then
    log("Spawned OC soldier handle: " .. tostring(h))
    
    -- Save globally to prevent garbage collection!
    _G.MyActiveOC = h
    
    -- Activate it using the wrapper
    local complete_fn = _MODULES.mrxsupportdelivery.MrxUtil._SpawnActorComplete
    pcall(complete_fn, h, "PersistentOC")
    
    -- Teleport directly next to player
    pcall(Object.SetPosition, h, px + 2, py, pz + 2)
    
    -- Make friendly
    pcall(Ai.SetAttitude, h, lc, 3)
    pcall(Ai.SetAttitude, lc, h, 3)
    
    -- Order to follow
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
    log("Spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
