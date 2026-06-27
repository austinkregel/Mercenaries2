local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local fm = _MODULES.vz.MrxFactionManager
if type(fm) == "table" and fm._tFactions then
    for name, data in pairs(fm._tFactions) do
        log(string.format("Faction name: %s => GUID: %s", tostring(name), tostring(data.uGuid)))
    end
else
    log("MrxFactionManager factions not found")
end

return table.concat(r, "\n")
