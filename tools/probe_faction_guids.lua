local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local fm = _MODULES.vz.MrxFactionManager
if type(fm) == "table" and type(fm._tFactions) == "table" then
    for k, v in pairs(fm._tFactions) do
        if type(v) == "table" then
            log(string.format("Faction '%s': Template=%s, PdaId=%s, Guid=%s",
                tostring(k), tostring(v.sFactionTemplate), tostring(v.sPdaFactionId), tostring(v.uGuid)))
        end
    end
end

return table.concat(r, "\n")
