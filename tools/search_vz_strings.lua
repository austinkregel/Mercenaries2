local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local found = {}

local function scan_table(t, depth)
    if depth > 6 then return end
    for k, v in pairs(t) do
        if type(k) == "string" then
            if string.find(k, "^[vV][zZ]") or string.find(k, "jeep") or string.find(k, "truck") or string.find(k, "heli") or string.find(k, "tank") then
                if not found[k] then
                    found[k] = true
                    log("Found key: " .. k .. " = " .. tostring(v))
                end
            end
        end
        if type(v) == "string" then
            if string.find(v, "^[vV][zZ]") or string.find(v, "jeep") or string.find(v, "truck") or string.find(v, "heli") or string.find(v, "tank") then
                local val = tostring(v)
                if not found[val] then
                    found[val] = true
                    log("Found string value: " .. val)
                end
            end
        elseif type(v) == "table" and k ~= "_G" and k ~= "_MODULES" and k ~= "package" then
            scan_table(v, depth + 1)
        end
    end
end

scan_table(_MODULES, 1)
scan_table(_G, 1)

return table.concat(r, "\n")
