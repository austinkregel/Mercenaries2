local r = {}

local function log(msg)
    r[#r+1] = tostring(msg)
end

local lp = Player.GetLocalPlayer()
local lc = Player.GetLocalCharacter()
local veh, seat = Object.InVehicle(lc)

if not veh then
    return "Not in vehicle"
end

local params = Vehicle.GetSeatParams(veh, seat)
local other_seat = params.StowSeatGuid
log("Driver seat handle: " .. tostring(seat))
log("Other seat handle (StowSeatGuid): " .. tostring(other_seat))

if other_seat then
    local occupant = Vehicle.GetRiderFromSeat(veh, other_seat)
    log("Occupant of other seat: " .. tostring(occupant))
    if occupant then
        log("Occupant is alive: " .. tostring(Object.IsAlive(occupant)))
        log("Occupant health: " .. tostring(Object.GetHealth(occupant)))
        log("Occupant is player controlled: " .. tostring(Object.IsPlayerControlled(occupant)))
    end

    local other_params = Vehicle.GetSeatParams(veh, other_seat)
    if type(other_params) == "table" then
        for k, v in pairs(other_params) do
            log(string.format("  OtherSeat.%s = %s", tostring(k), tostring(v)))
        end
    end
end

return table.concat(r, "\n")
