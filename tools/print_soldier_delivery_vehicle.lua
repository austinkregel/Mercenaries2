local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local sd = _MODULES.mrxsoldierdelivery
if type(sd) == "table" then
    for k, v in pairs(sd) do
        if type(v) == "table" then
            for kk, vv in pairs(v) do
                if kk == "sDeliveryVehicle" then
                    log(string.format("sd.%s.sDeliveryVehicle = %s (%s)", tostring(k), tostring(vv), type(vv)))
                end
            end
        elseif k == "sDeliveryVehicle" then
            log(string.format("sd.sDeliveryVehicle = %s (%s)", tostring(v), type(v)))
        end
    end
else
    log("mrxsoldierdelivery not found")
end

return table.concat(r, "\n")
