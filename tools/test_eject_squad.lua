local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

local template = "UH1 Transport (GR) (Full)"
log("Spawning helicopter: " .. template)
local ok, h = pcall(Pg.Spawn, template, px + 12, py, pz + 12, yaw, false, true)
if ok and h then
    log("Spawned helicopter handle: " .. tostring(h))
    
    _G.MyActiveSquadHeli2 = h
    
    -- Get all the riders
    local riders = {}
    local ok_riders, all_riders = pcall(Vehicle.GetRiders, h)
    if ok_riders and all_riders then
        for seat, rider in pairs(all_riders) do
            riders[#riders+1] = rider
            log(string.format("  Seat %s crew handle: %s", tostring(seat), tostring(rider)))
        end
    end
    
    -- Yank them out and command them to follow!
    local recruited = 0
    for i, rider in ipairs(riders) do
        _G["MySquad2Rider_" .. i] = rider
        
        -- Teleport them out of the heli onto the ground next to the player
        -- Spread them out slightly so they don't collision-clump
        local offset_x = 2.0 + (i * 0.8)
        local offset_z = 2.0 - (i * 0.8)
        pcall(Object.SetPosition, rider, px + offset_x, py, pz + offset_z)
        
        -- Set attitude Friendly
        pcall(Ai.SetAttitude, rider, lc, 3)
        pcall(Ai.SetAttitude, lc, rider, 3)
        
        -- Command to follow
        local tArgs = {
            AIGuid = rider,
            Role = "Follow",
            Target = lc,
            MinDistance = 2.0,
            MoveDistance = 4.0,
            MaxDistance = 50.0,
            Priority = "medPri"
        }
        local ok_role, err_role = pcall(Ai.Role, tArgs)
        if ok_role then
            recruited = recruited + 1
        end
    end
    
    log("Yanked & recruited: " .. recruited)
    
    if recruited > 0 then
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "5 Fresh Guerrilla Guards Spawned & Following!",
            nPriority = 1,
            nDuration = 6
        })
    end
else
    log("Heli spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
