local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

-- 1. Try spawning the PMC helicopter on the ground near the player
local template = "UH1 Transport (PMC) (Driver)"
log("Spawning vehicle: " .. template)
local ok, h = pcall(Pg.Spawn, template, px + 8, py, pz + 8, yaw, false, true)
if ok and h then
    log("Spawned vehicle handle: " .. tostring(h))
    
    -- Save globally to prevent GC
    _G.MySpawnedVehicle = h
    
    -- Let's check riders immediately
    local ok_riders, riders = pcall(Vehicle.GetRiders, h)
    if ok_riders and riders then
        log("Riders table type: " .. type(riders))
        for seat, rider in pairs(riders) do
            log(string.format("  Seat: %s => Rider: %s (HP: %s)",
                tostring(seat), tostring(rider), tostring(Object.GetHealth(rider))))
        end
    else
        log("Failed to get riders: " .. tostring(riders))
    end
else
    log("Spawn failed: " .. tostring(h))
end

return table.concat(r, "\n")
