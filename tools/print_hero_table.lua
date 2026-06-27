local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local mp = _MODULES.vz.MrxBootstrap.MrxPlayer
if type(mp) == "table" and mp.Hero then
    log("=== Keys in mp.Hero ===")
    for k, v in pairs(mp.Hero) do
        log(string.format("  %s = %s", tostring(k), tostring(v)))
    end
else
    log("MrxPlayer Hero not found")
end

return table.concat(r, "\n")
