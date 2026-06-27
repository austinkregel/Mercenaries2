local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

-- 1. Spawn the OC (Oil) soldier directly at target position with 7 args
local ok, h = pcall(Pg.Spawn, "OC", px + 2, py, pz + 2, yaw, false, true)
if ok and h then
    log("Spawned OC soldier handle: " .. tostring(h))
    
    -- Save globally to prevent GC
    _G.MyActiveOC = h
    
    -- 2. Set Position and Yaw FIRST (before enabling/disabling physics)
    pcall(Object.SetPosition, h, px + 2, py, pz + 2)
    pcall(Object.SetYaw, h, yaw)
    log("Set initial position and yaw")
    
    -- 3. Enable the AI
    pcall(Ai.Enable, h, false)
    log("Enabled AI via Ai.Enable(h, false)")
    
    -- 4. Disable physics (so animation engine takes control)
    pcall(Object.DisablePhysics, h)
    log("Disabled raw physics via Object.DisablePhysics(h)")
    
    -- Make friendly
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
            sMessage = "OC Guard Clone Spawned & Following!",
            nPriority = 1,
            nDuration = 6
        })
    end
else
    log("Spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
