local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

-- Spawn OC (Oil) soldier directly at player position with 7 args
local ok, h = pcall(Pg.Spawn, "OC", px + 2, py, pz + 2, yaw, false, true)
if ok and h then
    log("Spawned OC soldier: " .. tostring(h))
    
    -- Try enabling with true
    pcall(Ai.Enable, h, true)
    
    -- Try enabling physics
    pcall(Object.EnablePhysics, h)
    
    -- Set attitude to Friendly
    pcall(Ai.SetAttitude, h, lc, 3)
    pcall(Ai.SetAttitude, lc, h, 3)
    
    -- Let's check if it enters the active list
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
            sMessage = "OC Soldier Spawned & Physics Enabled!",
            nPriority = 1,
            nDuration = 5
        })
    end
else
    log("Spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
