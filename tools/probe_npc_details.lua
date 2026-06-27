local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local humans = Pg.FastCollectHumans()

log("Total humans collected: " .. #humans)

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

for i, h in ipairs(humans) do
    if h == lc then
        log(string.format("[%d] Local Player (%s)", i, tostring(h)))
    else
        log(string.format("[%d] NPC (%s):", i, tostring(h)))
        
        -- Health
        local hp = Object.GetHealth(h)
        local max_hp = Object.GetMaxHealth(h)
        log(string.format("  Health: %s/%s", tostring(hp), tostring(max_hp)))
        
        -- Faction
        local ok_fac, fac_guid = pcall(Ai.GetFactionGuid, h)
        if ok_fac and fac_guid then
            local f_name = faction_names[tostring(fac_guid)] or "Unknown Faction"
            log(string.format("  Faction GUID: %s (%s)", tostring(fac_guid), f_name))
        else
            log("  Faction: query failed: " .. tostring(fac_guid))
        end
        
        -- Vehicle
        local ok_veh, veh, seat = pcall(Object.InVehicle, h)
        if ok_veh then
            log(string.format("  In Vehicle: %s, Seat: %s", tostring(veh), tostring(seat)))
            if veh then
                local v_name = Object.GetName(veh) or "unnamed"
                local v_loc = Object.GetLocalizedName(veh) or "none"
                log(string.format("    Vehicle Name: %s, LocalizedName: %s", tostring(v_name), tostring(v_loc)))
            end
        else
            log("  Vehicle check failed: " .. tostring(veh))
        end
        
        -- Position
        local px, py, pz = Object.GetPosition(h)
        if px then
            log(string.format("  Position: %.2f, %.2f, %.2f", px, py, pz))
        end
        
        -- Yaw
        local yaw = Object.GetYaw(h)
        log(string.format("  Yaw: %s", tostring(yaw)))
    end
end

return table.concat(r, "\n")
