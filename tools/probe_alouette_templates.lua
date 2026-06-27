local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

local templates = {
    "Alouette 3 Transport (VZ) (Full)",
    "Alouette 3 Transport (Vza) (Full)",
    "Alouette3 Transport (VZ) (Full)",
    "Alouette3 Transport (Vza) (Full)",
    "alouette3transportvz",
    "alouette3transportvz (Full)",
    "Alouette 3 Transport (Full)",
    "Coanda Transport (Full)"
}

for _, template in ipairs(templates) do
    log("----------------------------------------")
    log("Trying VZ sky heli: " .. template)
    local ok, h = pcall(Pg.Spawn, template, px, py + 40, pz, yaw, false, true)
    if ok and h then
        log("  Spawned handle: " .. tostring(h))
        _G.MyProbeHeli = h
        
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
            log("    GetRiders failed: " .. tostring(riders))
        end
        pcall(Object.Remove, h)
    else
        log("  Spawn failed: " .. tostring(h))
    end
end

return table.concat(r, "\n")
