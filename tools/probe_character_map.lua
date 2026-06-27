local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local mp = _MODULES.vz.MrxBootstrap.MrxPlayer
if type(mp) == "table" then
    for k, v in pairs(mp) do
        if type(v) == "table" then
            log("MrxPlayer table key: " .. tostring(k))
            local count = 0
            for kk, vv in pairs(v) do
                count = count + 1
                if count <= 10 then
                    log(string.format("  [%s] = %s", tostring(kk), tostring(vv)))
                end
            end
            if count > 10 then
                log(string.format("  ... total %d entries", count))
            end
        end
    end
else
    log("MrxPlayer not found or not a table")
end

return table.concat(r, "\n")
