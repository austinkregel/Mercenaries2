local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

local template = "M35 (Guntruck) (VZ)"
log("Spawning vehicle: " .. template)
local ok, h = pcall(Pg.Spawn, template, px + 10, py, pz + 10, yaw, false, true)
if ok and h then
    log("Spawned vehicle handle: " .. tostring(h))
    _G.MyVZTruck = h
    
    local ok_riders, riders = pcall(Vehicle.GetRiders, h)
    if ok_riders and riders then
        local count = 0
        for seat, rider in pairs(riders) do
            count = count + 1
            log(string.format("  Seat %s: %s (HP: %s)",
                tostring(seat), tostring(rider), tostring(Object.GetHealth(rider))))
        end
        log("  Total riders: " .. count)
    else
        log("  Failed to get riders: " .. tostring(riders))
    end
else
    log("Spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
