-- Save original if not already saved
_G.OriginalGuiMinimapUpdate = _G.OriginalGuiMinimapUpdate or _MODULES.mrxguihudradar.oRadarObject.EventHandlers.GuiMinimapUpdate

local function get_sqrt(val)
    if val <= 0 then return 0 end
    local x = val / 2
    for i = 1, 4 do
        x = (x + val / x) / 2
    end
    return x
end

-- Resolve faction names
local faction_names = {}
local fm = _MODULES.vz.MrxFactionManager
if fm and fm._tFactions then
    for name, tbl in pairs(fm._tFactions) do
        if tbl.uGuid then
            faction_names[tostring(tbl.uGuid)] = name
        end
    end
end

-- Define the hijacked event handler
_MODULES.mrxguihudradar.oRadarObject.EventHandlers.GuiMinimapUpdate = function(self, tArgs)
    -- 1. Call original
    _G.OriginalGuiMinimapUpdate(self, tArgs)
    
    -- 2. Custom AI Tracking Logic
    pcall(function()
        local lc = Player.GetLocalCharacter()
        local px, py, pz = Object.GetPosition(lc)
        if not px then return end
        
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
            
            status_str = string.format("Track: %s (%s) | HP: %d/%d | Dist: %.1fm",
                fac_name, in_veh, hp, max_hp, dist)
        end
        
        -- Update the objective slot 1 text dynamically
        Hud.ObjectiveTray:SetSlotToText({
            vPlayer = Player.GetLocalPlayer(),
            nSlot = 1,
            sText = status_str,
            bDontNetSync = true
        })
    end)
end

return "Minimap GuiMinimapUpdate hooked successfully!"
