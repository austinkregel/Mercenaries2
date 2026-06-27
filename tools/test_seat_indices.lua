local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local veh, seat = Object.InVehicle(lc)

if not veh then
    return "Not in vehicle"
end

log("Vehicle: " .. tostring(veh))
log("Seat handle: " .. tostring(seat))

for i = 0, 4 do
    local ok_r, rider = pcall(Vehicle.GetRiderFromSeat, veh, i)
    log(string.format("RiderFromSeat(%d) => ok=%s, rider=%s", i, tostring(ok_r), tostring(rider)))
    if ok_r and rider then
        log(string.format("  Rider Name: %s", tostring(Object.GetName(rider))))
        log(string.format("  Rider IsPlayer: %s", tostring(Object.IsPlayerControlled(rider))))
    end

    local ok_p, params = pcall(Vehicle.GetSeatParams, veh, i)
    log(string.format("GetSeatParams(%d) => ok=%s, type=%s", i, tostring(ok_p), type(params)))
    if ok_p and type(params) == "table" then
        for k, v in pairs(params) do
            log(string.format("  SeatParams(%d).%s = %s", i, tostring(k), tostring(v)))
        end
    end
end

return table.concat(r, "\n")
