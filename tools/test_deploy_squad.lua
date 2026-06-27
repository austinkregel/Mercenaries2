local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

-- 1. Spawn the transport helicopter with a full crew of Guerrillas
local template = "UH1 Transport (GR) (Full)"
log("Spawning helicopter: " .. template)
local ok, h = pcall(Pg.Spawn, template, px + 10, py, pz + 10, yaw, false, true)
if ok and h then
    log("Spawned helicopter handle: " .. tostring(h))
    
    -- Save globally to prevent GC
    _G.MyActiveSquadHeli = h
    
    -- 2. Get the riders first (before deploying them, as they will leave the vehicle!)
    local riders = {}
    local ok_riders, all_riders = pcall(Vehicle.GetRiders, h)
    if ok_riders and all_riders then
        for seat, rider in pairs(all_riders) do
            riders[#riders+1] = rider
            log(string.format("  Found crew in seat %s: %s", tostring(seat), tostring(rider)))
        end
    end
    
    -- 3. Deploy all passengers (command them to exit the vehicle)
    local ok_dep, err_dep = pcall(Vehicle.Deploy, h, true)
    log("Deploy command sent: " .. tostring(ok_dep))
    
    -- 4. Set attitude to Friendly and command to follow for each soldier
    local recruited = 0
    for i, rider in ipairs(riders) do
        -- Save them in global refs to prevent GC!
        _G["MySquadRider_" .. i] = rider
        
        -- Set attitude Friendly (3)
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
    
    log("Successfully recruited " .. recruited .. " bodyguards!")
    
    if recruited > 0 then
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "HELICOPTER SQUAD DEPLOYED & RECRUITED!",
            nPriority = 1,
            nDuration = 6
        })
    end
else
    log("Heli spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
