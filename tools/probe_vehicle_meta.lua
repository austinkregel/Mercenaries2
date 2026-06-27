local r = {}

local function log(msg)
    r[#r+1] = tostring(msg)
end

local lc = Player.GetLocalCharacter()
local veh, seat = Object.InVehicle(lc)

if not veh then
    return "Not in vehicle"
end

log("Vehicle userdata: " .. tostring(veh))
local mt = getmetatable(veh)
log("Vehicle metatable: " .. tostring(mt))

if type(mt) == "table" then
    for k, v in pairs(mt) do
        log(string.format("  mt[%s] = %s (%s)", tostring(k), tostring(v), type(v)))
    end
else
    log("Metatable is not a table")
end

log("Seat userdata: " .. tostring(seat))
local seat_mt = getmetatable(seat)
log("Seat metatable: " .. tostring(seat_mt))
if type(seat_mt) == "table" then
    for k, v in pairs(seat_mt) do
        log(string.format("  seat_mt[%s] = %s (%s)", tostring(k), tostring(v), type(v)))
    end
end

return table.concat(r, "\n")
