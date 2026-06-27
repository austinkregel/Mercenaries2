local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local fm = _MODULES.mrxtaskmission.MrxRewardData.MrxFactionManager
if fm and fm._tFactionTemplateToAbbrev then
    for k, v in pairs(fm._tFactionTemplateToAbbrev) do
        log(string.format("Faction template: %s => %s", tostring(k), tostring(v)))
    end
else
    log("FactionTemplateToAbbrev not found")
end

return table.concat(r, "\n")
