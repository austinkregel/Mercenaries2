local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local allied = _MODULES.vz.MrxFactionManager._tFactions.All.uGuid
local oil = _MODULES.vz.MrxFactionManager._tFactions.Oil.uGuid

local orig = Ai.GetRelation(allied, oil)
log("Original relation Allied <-> Oil: " .. tostring(orig))

-- Test SetRelation
local ok1 = pcall(Ai.SetRelation, allied, oil, 85)
log("SetRelation(allied, oil, 85) => " .. tostring(ok1))
local new_rel1 = Ai.GetRelation(allied, oil)
log("New relation: " .. tostring(new_rel1))

-- Test ChangeRelation
local ok2 = pcall(Ai.ChangeRelation, allied, oil, -15)
log("ChangeRelation(allied, oil, -15) => " .. tostring(ok2))
local new_rel2 = Ai.GetRelation(allied, oil)
log("New relation after change: " .. tostring(new_rel2))

-- Restore original relation
pcall(Ai.SetRelation, allied, oil, orig)
log("Restored relation: " .. tostring(Ai.GetRelation(allied, oil)))

-- Test SetAttitude
log("Testing SetAttitude...")
for att = 1, 3 do
    local ok_att = pcall(Ai.SetAttitude, allied, oil, att)
    log(string.format("  SetAttitude(allied, oil, %d) => ok=%s", att, tostring(ok_att)))
end

-- Print faction min/max relation constants
local fm = _MODULES.vz.MrxFactionManager
if type(fm) == "table" then
    log("fm._knRelationMin = " .. tostring(fm._knRelationMin))
    log("fm._knRelationMax = " .. tostring(fm._knRelationMax))
end

return table.concat(r, "\n")
