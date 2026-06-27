local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local fm = _MODULES.vz.MrxFactionManager
log("MrxFactionManager type: " .. type(fm))
if type(fm) == "table" then
    if type(fm._tFactions) == "table" then
        log("=== Factions ===")
        for k, v in pairs(fm._tFactions) do
            log(string.format("  [%s] = %s (%s)", tostring(k), tostring(v), type(v)))
        end
    else
        log("fm._tFactions is not a table")
    end

    if type(fm._tAttitudes) == "table" then
        log("=== Attitudes ===")
        for k, v in pairs(fm._tAttitudes) do
            log(string.format("  [%s] = %s", tostring(k), tostring(v)))
        end
    end
end

return table.concat(r, "\n")
