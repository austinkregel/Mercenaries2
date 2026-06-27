local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()
local lc = Player.GetLocalCharacter()
local veh, seat = Object.InVehicle(lc)

log("Local Player: " .. tostring(lp))
log("Local Character: " .. tostring(lc))
log("Vehicle: " .. tostring(veh))

local x, y, z, obj = Player.GetTargetUnderReticle(lp)
log(string.format("Reticle Target: x=%s, y=%s, z=%s, obj=%s", tostring(x), tostring(y), tostring(z), tostring(obj)))

if obj then
    log("Target is valid: " .. tostring(Object.IsValid(obj)))
    log("Target physics type: " .. tostring(Object.GetPhysicsType(obj)))
    local target_veh, target_seat = Object.InVehicle(obj)
    log(string.format("Target in vehicle: %s, seat: %s", tostring(target_veh), tostring(target_seat)))
    if target_veh then
        local params = Vehicle.GetSeatParams(target_veh, target_seat)
        if type(params) == "table" then
            for k, v in pairs(params) do
                log(string.format("  Seat.%s = %s", tostring(k), tostring(v)))
            end
        end
    end
end

return table.concat(r, "\n")
