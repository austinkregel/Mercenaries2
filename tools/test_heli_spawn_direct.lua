local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Pos: %.2f, %.2f, %.2f", px, py, pz))

local template = "UH1 Transport (GR) (Full)"
local ok, hl = pcall(Pg.Spawn, template, px + 15, py + 15, pz + 15, yaw, false, true)
log(string.format("Spawn ok=%s, handle=%s", tostring(ok), tostring(hl)))

if ok and hl then
    local ok_riders, riders = pcall(Vehicle.GetRiders, hl)
    if ok_riders and riders then
        local count = 0
        for seat, rider in pairs(riders) do
            count = count + 1
            log(string.format("  Seat %s: %s", tostring(seat), tostring(rider)))
        end
        log("  Total riders: " .. count)
    else
        log("  GetRiders failed: " .. tostring(riders))
    end
    pcall(Object.Remove, hl)
    log("  Removed vehicle")
end

return table.concat(r, "\n")
