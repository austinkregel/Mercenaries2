local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

-- Define the wave defense system in a global table to survive GC
_G.WaveDefense = {
    active = false,
    wave = 0,
    enemies = {},
    kills = 0,
    cash_reward = 5000,
    pmc_guid = userdata("800056C4"),
    gur_guid = userdata("80002CF1")
}

-- Start Wave function
_G.WaveDefense.StartWave = function()
    if not _G.WaveDefense.active then return end
    
    _G.WaveDefense.wave = _G.WaveDefense.wave + 1
    _G.WaveDefense.enemies = {}
    
    local lc = Player.GetLocalCharacter()
    local px, py, pz = Object.GetPosition(lc)
    local yaw = Object.GetYaw(lc)
    
    -- Show Fanfare
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = "WAVE " .. _G.WaveDefense.wave .. " STARTING!",
        nPriority = 1,
        nDuration = 5
    })
    
    -- Set Guerrillas to Hostile (1)
    pcall(Ai.SetAttitude, _G.WaveDefense.pmc_guid, _G.WaveDefense.gur_guid, 1)
    pcall(Ai.SetAttitude, _G.WaveDefense.gur_guid, _G.WaveDefense.pmc_guid, 1)
    pcall(Ai.SetRelation, _G.WaveDefense.pmc_guid, _G.WaveDefense.gur_guid, -100)
    pcall(Ai.SetRelation, _G.WaveDefense.gur_guid, _G.WaveDefense.pmc_guid, -100)
    
    -- Determine helicopters to spawn (progressive difficulty)
    -- Wave 1: 1 heli (5 enemies)
    -- Wave 2: 2 helis (10 enemies)
    local num_helis = math.ceil(_G.WaveDefense.wave / 2)
    local spawn_count = 0
    
    for w = 1, num_helis do
        -- Spawn heli in the sky (py + 45) to prevent collision crashes
        -- Spread out the spawn position slightly
        local sx = px + 40 + (w * 5)
        local sz = pz + 40 - (w * 5)
        local ok, heli = pcall(Pg.Spawn, "UH1 Transport (GR) (Full)", sx, py + 45, sz, yaw, false, true)
        if ok and heli then
            -- Get riders
            local ok_riders, riders = pcall(Vehicle.GetRiders, heli)
            if ok_riders and riders then
                for seat, rider in pairs(riders) do
                    -- Prevent GC
                    local index = #_G.WaveDefense.enemies + 1
                    _G["WaveEnemy_" .. index] = rider
                    table.insert(_G.WaveDefense.enemies, rider)
                    spawn_count = spawn_count + 1
                    
                    -- Eject rider directly onto the ground
                    pcall(Object.SetPosition, rider, sx + (seat * 0.8), py, sz - (seat * 0.8))
                    
                    -- Set individual attitude to Hostile
                    pcall(Ai.SetAttitude, rider, lc, 1)
                    pcall(Ai.SetAttitude, lc, rider, 1)
                    
                    -- Command to seek the player
                    local tArgs = {
                        AIGuid = rider,
                        Role = "Follow",
                        Target = lc,
                        MinDistance = 4.0,
                        MoveDistance = 8.0,
                        MaxDistance = 150.0,
                        Priority = "medPri"
                    }
                    pcall(Ai.Role, tArgs)
                end
            end
            
            -- Remove helicopter instantly
            pcall(Object.Remove, heli)
        end
    end
    
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = spawn_count .. " HOSTILE SOLDIERS DEPLOYED!",
        nPriority = 1,
        nDuration = 4
    })
    
    -- Start the tick check
    pcall(Event.Create, Event.TimerRelative, { 1.0 }, _G.WaveDefense.Tick)
end

-- Wave Tick loop
_G.WaveDefense.Tick = function()
    if not _G.WaveDefense.active then return end
    
    local lc = Player.GetLocalCharacter()
    if not lc or not Object.IsValid(lc) or not Object.IsAlive(lc) or Object.GetHealth(lc) <= 0 then
        -- Player Died - Game Over!
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "GAME OVER! WAVE REACHED: " .. _G.WaveDefense.wave .. " | TOTAL KILLS: " .. _G.WaveDefense.kills,
            nPriority = 1,
            nDuration = 8
        })
        _G.WaveDefense.Stop()
        return
    end
    
    -- Check active enemies
    local remaining = {}
    for _, enemy in ipairs(_G.WaveDefense.enemies) do
        if Object.IsValid(enemy) and Object.IsAlive(enemy) and Object.GetHealth(enemy) > 0 then
            table.insert(remaining, enemy)
            
            -- Re-enforce follow behavior/attitude periodically to prevent resets
            pcall(Ai.SetAttitude, enemy, lc, 1)
            pcall(Ai.SetAttitude, lc, enemy, 1)
        else
            -- Enemy Died!
            _G.WaveDefense.kills = _G.WaveDefense.kills + 1
            
            -- Add Cash reward to player!
            local reward = _G.WaveDefense.cash_reward * _G.WaveDefense.wave
            pcall(Player.AddCash, Player.GetLocalPlayer(), reward)
            
            Hud.MessageBox:AddMessage({
                vPlayer = Player.GetLocalPlayer(),
                sMessage = "Enemy Eliminated! +$" .. reward,
                nPriority = 1,
                nDuration = 2
            })
        end
    end
    _G.WaveDefense.enemies = remaining
    
    if #_G.WaveDefense.enemies == 0 then
        -- Wave Cleared!
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "WAVE " .. _G.WaveDefense.wave .. " CLEARED!",
            nPriority = 1,
            nDuration = 5
        })
        
        -- Schedule next wave in 5 seconds
        pcall(Event.Create, Event.TimerRelative, { 5.0 }, _G.WaveDefense.StartWave)
    else
        -- Schedule next tick in 1 second
        pcall(Event.Create, Event.TimerRelative, { 1.0 }, _G.WaveDefense.Tick)
    end
end

-- Stop Gamemode function
_G.WaveDefense.Stop = function()
    _G.WaveDefense.active = false
    
    -- Reset relations back to Friendly (3)
    pcall(Ai.SetAttitude, _G.WaveDefense.pmc_guid, _G.WaveDefense.gur_guid, 3)
    pcall(Ai.SetAttitude, _G.WaveDefense.gur_guid, _G.WaveDefense.pmc_guid, 3)
    pcall(Ai.SetRelation, _G.WaveDefense.pmc_guid, _G.WaveDefense.gur_guid, 100)
    pcall(Ai.SetRelation, _G.WaveDefense.gur_guid, _G.WaveDefense.pmc_guid, 100)
    
    -- Remove any remaining enemies
    for _, enemy in ipairs(_G.WaveDefense.enemies) do
        if Object.IsValid(enemy) then
            pcall(Object.Remove, enemy)
        end
    end
    _G.WaveDefense.enemies = {}
    
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = "WAVE DEFENSE STOPPED. RELATIONS RESET.",
        nPriority = 1,
        nDuration = 5
    })
end

-- Start Gamemode
_G.WaveDefense.active = true
_G.WaveDefense.wave = 0
_G.WaveDefense.kills = 0
_G.WaveDefense.StartWave()

log("Wave Defense Gamemode successfully initialized and started!")

return table.concat(r, "\n")
