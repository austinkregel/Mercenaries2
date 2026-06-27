local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

local templates = {
    "UH1 Transport (GR) (Full)",
    "UH1 Transport (OC) (Full)",
    "UH1 Transport (Oil) (Full)",
    "UH1 Transport (PMC) (Full)",
    "UH1 Transport (Allied) (Full)"
}

for _, template in ipairs(templates) do
    log("----------------------------------------")
    log("Trying template: " .. template)
    local ok, h = pcall(Pg.Spawn, template, px + 12, py, pz + 12, yaw, false, true)
    if ok and h then
        log("Spawned handle: " .. tostring(h))
        _G["Vehicle_" .. string.gsub(template, "%W", "")] = h
        
        local ok_riders, riders = pcall(Vehicle.GetRiders, h)
        if ok_riders and riders then
            local count = 0
            for seat, rider in pairs(riders) do
                count = count + 1
                log(string.format("  Seat: %s => Rider: %s (HP: %s)",
                    tostring(seat), tostring(rider), tostring(Object.GetHealth(rider))))
            end
            log("  Total riders: " .. count)
        else
            log("  No riders or failed: " .. tostring(riders))
        end
    else
        log("Spawn failed: " .. tostring(h))
    end
end

return table.concat(r, "\n")
