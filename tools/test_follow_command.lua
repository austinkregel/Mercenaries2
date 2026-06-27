local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)

local humans = Pg.FastCollectHumans()
local target = nil
local min_dist = 9999999
for _, h in ipairs(humans) do
    if h ~= lc and Object.IsValid(h) and Object.IsAlive(h) then
        local hx, hy, hz = Object.GetPosition(h)
        if hx then
            local dist = (hx-px)*(hx-px) + (hy-py)*(hy-py) + (hz-pz)*(hz-pz)
            if dist < min_dist then
                min_dist = dist
                target = h
            end
        end
    end
end

if not target then
    return "No AI target found to command!"
end

-- Resolve faction name
local faction_names = {}
local fm = _MODULES.vz.MrxFactionManager
if fm and fm._tFactions then
    for name, tbl in pairs(fm._tFactions) do
        if tbl.uGuid then
            faction_names[tostring(tbl.uGuid)] = name
        end
    end
end

local fac_name = "Unknown"
local ok_fac, fac_guid = pcall(Ai.GetFactionGuid, target)
if ok_fac and fac_guid then
    fac_name = faction_names[tostring(fac_guid)] or "Unknown"
end

log("Target NPC: " .. tostring(target) .. " (" .. fac_name .. ")")

-- Command to follow
local tArgs = {
    AIGuid = target,
    Role = "Follow",
    Target = lc,
    MinDistance = 2.0, -- keep them close!
    MoveDistance = 4.0,
    MaxDistance = 50.0,
    Priority = "medPri"
}

local ok_role, err_role = pcall(Ai.Role, tArgs)
log(string.format("Ai.Role => ok=%s, err=%s", tostring(ok_role), tostring(err_role)))

if ok_role then
    local status = string.format("Commanded %s NPC to Follow!", fac_name)
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = status,
        nPriority = 1,
        nDuration = 5
    })
end

return table.concat(r, "\n")
