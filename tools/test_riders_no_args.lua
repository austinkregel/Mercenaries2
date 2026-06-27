local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()
local lc = Player.GetLocalCharacter()
local veh, seat = Object.InVehicle(lc)

if not veh then
    return "Not in vehicle"
end

local res = Vehicle.GetRiders()
log("GetRiders() type: " .. type(res))
if type(res) == "table" then
    log("GetRiders() count: " .. #res)
    for k, v in pairs(res) do log(string.format("  [%s] = %s", tostring(k), tostring(v))) end
end

local res2 = Vehicle.GetRiders(veh)
log("GetRiders(veh) type: " .. type(res2))
if type(res2) == "table" then
    log("GetRiders(veh) count: " .. #res2)
    for k, v in pairs(res2) do log(string.format("  [%s] = %s", tostring(k), tostring(v))) end
end

return table.concat(r, "\n")
