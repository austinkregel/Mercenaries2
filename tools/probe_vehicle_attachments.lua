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

local atts = Object.GetAttachedObjects(veh)
log("Vehicle attached objects type: " .. type(atts))
if type(atts) == "table" then
    log("Number of attachments: " .. #atts)
    for k, v in pairs(atts) do
        log(string.format("  [%s] = %s", tostring(k), tostring(v)))
        local ok, ptype = pcall(Object.GetPhysicsType, v)
        log(string.format("    PhysicsType: %s", tostring(ptype)))
        local ok_name, name = pcall(Object.GetName, v)
        log(string.format("    Name: %s", tostring(name)))
        local ok_loc, loc = pcall(Object.GetLocalizedName, v)
        log(string.format("    LocalizedName: %s", tostring(loc)))
    end
else
    log("Attachments value: " .. tostring(atts))
end

return table.concat(r, "\n")
