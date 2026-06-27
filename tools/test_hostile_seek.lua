local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

local template = "UH1 Transport (GR) (Full)"
-- Spawn helicopter 45 meters away
local ok, h = pcall(Pg.Spawn, template, px + 35, py, pz + 35, yaw, false, true)
if ok and h then
    log("Spawned hostile heli: " .. tostring(h))
    
    _G.MyHostileHeli = h
    
    -- Extract crew
    local riders = {}
    local ok_riders, all_riders = pcall(Vehicle.GetRiders, h)
    if ok_riders and all_riders then
        for seat, rider in pairs(all_riders) do
            riders[#riders+1] = rider
        end
    end
    
    log("Found " .. #riders .. " crew members. Ejecting and making them hostile...")
    for i, rider in ipairs(riders) do
        _G["MyHostileRider_" .. i] = rider
        
        -- Eject to the ground near the spawned helicopter
        pcall(Object.SetPosition, rider, px + 35 + (i * 0.5), py, pz + 35 - (i * 0.5))
        
        -- Set attitude to Hostile (1)
        pcall(Ai.SetAttitude, rider, lc, 1)
        pcall(Ai.SetAttitude, lc, rider, 1)
        
        -- Command to follow (seek) the player
        local tArgs = {
            AIGuid = rider,
            Role = "Follow",
            Target = lc,
            MinDistance = 5.0,
            MoveDistance = 10.0,
            MaxDistance = 100.0,
            Priority = "medPri"
        }
        pcall(Ai.Role, tArgs)
    end
    
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = "HOSTILE GUERRILLAS SPAWNED 40M AWAY!",
        nPriority = 1,
        nDuration = 5
    })
else
    log("Failed to spawn hostile heli: " .. tostring(h))
end

return table.concat(r, "\n")
