local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

for mod_name, mod in pairs(_MODULES) do
    if type(mod) == "table" and mod.sDeliveryVehicle then
        log(string.format("Module %s sDeliveryVehicle = %s", mod_name, tostring(mod.sDeliveryVehicle)))
    elseif type(mod) == "table" then
        local index = mod.__index
        if type(index) == "table" and index.sDeliveryVehicle then
            log(string.format("Module %s (index) sDeliveryVehicle = %s", mod_name, tostring(index.sDeliveryVehicle)))
        end
    end
end

return table.concat(r, "\n")
