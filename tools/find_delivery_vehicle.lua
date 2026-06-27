local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local function search_table(t, name, depth)
    if depth > 5 then return end
    for k, v in pairs(t) do
        if k == "sDeliveryVehicle" then
            log(name .. ".sDeliveryVehicle = " .. tostring(v))
        elseif type(v) == "table" and k ~= "_G" and k ~= "_MODULES" and k ~= "package" then
            search_table(v, name .. "." .. tostring(k), depth + 1)
        end
    end
end

search_table(_MODULES, "_MODULES", 1)

return table.concat(r, "\n")
