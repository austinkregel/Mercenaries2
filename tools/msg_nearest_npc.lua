local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local function get_sqrt(val)
    if val <= 0 then return 0 end
    local x = val / 2
    for i = 1, 4 do
        x = (x + val / x) / 2
    end
    return x
end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)

-- Map of faction GUIDs to names
local faction_names = {}
local fm = _MODULES.vz.MrxFactionManager
if fm and fm._tFactions then
    for name, tbl in pairs(fm._tFactions) do
        if tbl.uGuid then
            faction_names[tostring(tbl.uGuid)] = name
        end
    end
end

local humans = Pg.FastCollectHumans()
local nearest_h = nil
local min_dist_sq = 99999999

for _, h in ipairs(humans) do
    if h ~= lc and Object.IsValid(h) and Object.IsAlive(h) then
        local hx, hy, hz = Object.GetPosition(h)
        if hx then
            local dx = hx - px
            local dy = hy - py
            local dz = hz - pz
            local dist_sq = dx*dx + dy*dy + dz*dz
            if dist_sq < min_dist_sq then
                min_dist_sq = dist_sq
                nearest_h = h
            end
        end
    end
end

local status_str = "No active AI nearby"
if nearest_h then
    local dist = get_sqrt(min_dist_sq)
    local hp = Object.GetHealth(nearest_h) or 0
    local max_hp = Object.GetMaxHealth(nearest_h) or 100
    
    local fac_name = "Unknown"
    local ok_fac, fac_guid = pcall(Ai.GetFactionGuid, nearest_h)
    if ok_fac and fac_guid then
        fac_name = faction_names[tostring(fac_guid)] or "Unknown"
    end
    
    local in_veh = "Foot"
    local ok_veh, veh = pcall(Object.InVehicle, nearest_h)
    if ok_veh and veh then
        in_veh = "Vehicle"
    end
    
    status_str = string.format("Nearest AI: %s (%s) | HP: %d/%d | Dist: %.1fm",
        fac_name, in_veh, hp, max_hp, dist)
end

log("Nearest AI status: " .. status_str)

-- Print to game top screen message box
local ok_msg, err_msg = pcall(Hud.MessageBox.AddMessage, Hud.MessageBox, {
    vPlayer = Player.GetLocalPlayer(),
    sMessage = status_str,
    nPriority = 1,
    nDuration = 6
})
log(string.format("AddMessage status => ok=%s, err=%s", tostring(ok_msg), tostring(err_msg)))

return table.concat(r, "\n")
