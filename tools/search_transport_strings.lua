local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local found = {}

local function scan_table(t, depth)
    if depth > 6 then return end
    for k, v in pairs(t) do
        if type(v) == "string" and string.find(v, "[Tt]ransport") then
            if not found[v] then
                found[v] = true
                log("Found Transport string: " .. v)
            end
        end
        if type(v) == "table" and k ~= "_G" and k ~= "_MODULES" and k ~= "package" then
            scan_table(v, depth + 1)
        end
    end
end

scan_table(_MODULES, 1)
scan_table(_G, 1)

return table.concat(r, "\n")
