local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

local templates = {
    "VZ Jeep (Full)",
    "vz_jeep_hmg",
    "VZ Jeep",
    "VZ Transport",
    "vz_truck",
    "VZ Tank"
}

for _, template in ipairs(templates) do
    log("----------------------------------------")
    log("Trying VZ template: " .. template)
    local ok, h = pcall(Pg.Spawn, template, px + 20, py, pz + 20, yaw, false, true)
    if ok and h then
        log("  Spawned handle: " .. tostring(h))
        _G["VZ_Vehicle_" .. string.gsub(template, "%W", "")] = h
        
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
            log("    No riders/failed: " .. tostring(riders))
        end
    else
        log("  Spawn failed: " .. tostring(h))
    end
end

return table.concat(r, "\n")
