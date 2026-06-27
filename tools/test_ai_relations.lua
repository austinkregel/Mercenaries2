local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local allied = _MODULES.vz.MrxFactionManager._tFactions.All.uGuid
local vza = _MODULES.vz.MrxFactionManager._tFactions.Vza.uGuid
local oil = _MODULES.vz.MrxFactionManager._tFactions.Oil.uGuid

log(string.format("allied=%s, vza=%s, oil=%s, player_char=%s",
    tostring(allied), tostring(vza), tostring(oil), tostring(lc)))

local function test(label, fn, ...)
    local ok, val = pcall(fn, ...)
    log(string.format("%s => ok=%s, val=%s", label, tostring(ok), tostring(val)))
end

test("GetRelation(allied, vza)", Ai.GetRelation, allied, vza)
test("GetRelation(vza, allied)", Ai.GetRelation, vza, allied)
test("GetRelation(lc, allied)", Ai.GetRelation, lc, allied)
test("GetRelation(lc, vza)", Ai.GetRelation, lc, vza)

test("GetRelation('Allied', 'Vza')", Ai.GetRelation, 'Allied', 'Vza')
test("GetRelation('All', 'Vza')", Ai.GetRelation, 'All', 'Vza')

test("GetFactionGuid('Allied')", Ai.GetFactionGuid, 'Allied')
test("GetFactionGuid('All')", Ai.GetFactionGuid, 'All')
test("GetFactionGuid('AN')", Ai.GetFactionGuid, 'AN')
test("GetFactionGuid('Allied')", Ai.GetFactionGuid, 'Allied')
test("GetFactionGuid('OC')", Ai.GetFactionGuid, 'OC')
test("GetFactionGuid('Oil')", Ai.GetFactionGuid, 'Oil')

return table.concat(r, "\n")
