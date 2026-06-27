local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

local templates = {
    "UH1 Transport (VZ) (Full)",
    "UH1 Transport (Vza) (Full)"
}

for _, template in ipairs(templates) do
    log("----------------------------------------")
    log("Spawning sky heli: " .. template)
    -- Spawn 40 meters in the air
    local ok, h = pcall(Pg.Spawn, template, px, py + 40, pz, yaw, false, true)
    if ok and h then
        log("  Spawned handle: " .. tostring(h))
        _G.MySkyHeli = h
        
        local ok_riders, riders = pcall(Vehicle.GetRiders, h)
        if ok_riders and riders then
            local count = 0
            for seat, rider in pairs(riders) do
                count = count + 1
                log(string.format("    Seat %s: %s (HP: %s)",
                    tostring(seat), tostring(rider), tostring(Object.GetHealth(rider))))
            end
            log("    Total riders: " .. count)
        else
            log("    Failed to get riders: " .. tostring(riders))
        end
        
        -- Clean up vehicle instantly
        pcall(Object.Remove, h)
        log("  Removed sky heli")
    else
        log("  Spawn failed: " .. tostring(h))
    end
end

return table.concat(r, "\n")
