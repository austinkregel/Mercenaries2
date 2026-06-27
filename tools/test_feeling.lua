local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local allied = _MODULES.vz.MrxFactionManager._tFactions.All.uGuid

local ok1, val1 = pcall(Ai.GetFeeling, lc, allied)
log(string.format("GetFeeling(lc, allied) => ok=%s, val=%s", tostring(ok1), tostring(val1)))

local ok2, val2 = pcall(Ai.GetFeeling, lc, lc)
log(string.format("GetFeeling(lc, lc) => ok=%s, val=%s", tostring(ok2), tostring(val2)))

local ok3, val3 = pcall(Ai.GetFeeling, allied, allied)
log(string.format("GetFeeling(allied, allied) => ok=%s, val=%s", tostring(ok3), tostring(val3)))

return table.concat(r, "\n")
