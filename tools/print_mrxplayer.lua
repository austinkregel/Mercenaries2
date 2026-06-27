local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local mp = _MODULES.vz.MrxBootstrap.MrxPlayer
if type(mp) == "table" then
    log("=== Keys in MrxPlayer ===")
    for k, v in pairs(mp) do
        log(string.format("  %s = %s (%s)", tostring(k), tostring(v), type(v)))
    end
else
    log("MrxPlayer not found or not a table")
end

return table.concat(r, "\n")
