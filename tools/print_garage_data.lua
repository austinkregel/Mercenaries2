local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local g = _MODULES.wifpmcgarage
if type(g) == "table" then
    for k, v in pairs(g) do
        log(string.format("Key: %s = %s (%s)", tostring(k), tostring(v), type(v)))
        if type(v) == "table" then
            local count = 0
            for kk, vv in pairs(v) do
                count = count + 1
                if count <= 5 then
                    log(string.format("  [%s] = %s", tostring(kk), tostring(vv)))
                end
            end
            if count > 5 then
                log(string.format("  ... total %d entries", count))
            end
        end
    end
else
    log("wifpmcgarage not found")
end

return table.concat(r, "\n")
