local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

-- 1. Spawn OC soldier (7 arguments)
local ok, h = pcall(Pg.Spawn, "OC", px + 2, py, pz + 2, yaw, false, true)
if ok and h then
    log("Spawned OC soldier handle: " .. tostring(h))
    
    -- Prevent GC
    _G.MyWorldOC = h
    
    -- 2. Set Position and Yaw
    pcall(Object.SetPosition, h, px + 2, py, pz + 2)
    pcall(Object.SetYaw, h, yaw)
    
    -- 3. Activate (using mrxutil sequence)
    pcall(Ai.Enable, h, false)
    pcall(Object.DisablePhysics, h)
    
    -- 4. Set attitude to Friendly
    pcall(Ai.SetAttitude, h, lc, 3)
    pcall(Ai.SetAttitude, lc, h, 3)
    
    -- 5. Command to follow
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
    
    -- Immediately read back position
    local hx, hy, hz = Object.GetPosition(h)
    log(string.format("Spawned immediate position: %.2f, %.2f, %.2f", hx, hy, hz))
    
    if ok_role then
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "Fresh OC Soldier Spawned & Activated!",
            nPriority = 1,
            nDuration = 6
        })
    end
else
    log("Spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
