local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

local ok, h = pcall(Pg.Spawn, "VZ", px + 15, py, pz + 15, yaw, false, true)
if ok and h then
    log("Spawned VZ soldier handle: " .. tostring(h))
    
    _G.MyTestVZDirect = h
    
    pcall(Object.SetPosition, h, px + 15, py, pz + 15)
    pcall(Object.SetYaw, h, yaw)
    
    pcall(Ai.Enable, h, false)
    pcall(Object.DisablePhysics, h)
    
    pcall(Ai.SetAttitude, h, lc, 1)
    pcall(Ai.SetAttitude, lc, h, 1)
    
    -- Command to follow/seek
    local tArgs = {
        AIGuid = h,
        Role = "Follow",
        Target = lc,
        MinDistance = 4.0,
        MoveDistance = 8.0,
        MaxDistance = 150.0,
        Priority = "medPri"
    }
    pcall(Ai.Role, tArgs)
    
    -- Check active list after a frame or immediately
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
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "VZ Soldier Spawned & Seeking player!",
            nPriority = 1,
            nDuration = 5
        })
    end
else
    log("Spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
