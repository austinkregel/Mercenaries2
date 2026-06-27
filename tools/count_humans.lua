local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local humans = Pg.FastCollectHumans()
log("Total humans now: " .. #humans)
for i, h in ipairs(humans) do
    local name = Object.GetName(h) or "unnamed"
    local locName = Object.GetLocalizedName(h) or "none"
    local hp = Object.GetHealth(h)
    local px, py, pz = Object.GetPosition(h)
    log(string.format("  [%d] Handle=%s, Name=%s, LocalName=%s, HP=%s, Pos=(%.1f, %.1f)",
        i, tostring(h), tostring(name), tostring(locName), tostring(hp), px or 0, pz or 0))
end

return table.concat(r, "\n")
