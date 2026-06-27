local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

-- Spawn a PMC soldier (fully loaded in memory at PMC HQ)
local ok, h = pcall(Pg.Spawn, "PMC", px + 2, py, pz + 2, yaw, false, true)
if ok and h then
    log("Spawned PMC soldier handle: " .. tostring(h))
    
    -- Activate it
    local complete_fn = _MODULES.mrxsupportdelivery.MrxUtil._SpawnActorComplete
    pcall(complete_fn, h, "SpawnedPMC")
    
    -- Teleport to make sure it is exactly in front
    pcall(Object.SetPosition, h, px + 2, py, pz + 2)
    
    -- Set Friendly attitude
    pcall(Ai.SetAttitude, h, lc, 3)
    pcall(Ai.SetAttitude, lc, h, 3)
    
    -- Command to follow
    local tArgs = {
        AIGuid = h,
        Role = "Follow",
        Target = lc,
        MinDistance = 2.0,
        MoveDistance = 4.0,
        MaxDistance = 50.0,
        Priority = "medPri"
    }
    local ok_role, err_role = pcall(Ai.Role, tArgs)
    log(string.format("Ai.Role => ok=%s, err=%s", tostring(ok_role), tostring(err_role)))
    
    if ok_role then
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "Spawned PMC Soldier following you!",
            nPriority = 1,
            nDuration = 5
        })
    end
else
    log("Spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
