local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local ok, humans = pcall(Pg.FastCollectHumans)
if not ok then
    return "FastCollectHumans failed: " .. tostring(humans)
end

log("FastCollectHumans returned type: " .. type(humans))
if type(humans) ~= "table" then
    return table.concat(r, "\n")
end

log("Number of humans collected: " .. #humans)

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)

for i, h in ipairs(humans) do
    local valid = Object.IsValid(h)
    local alive = Object.IsAlive(h)
    local name = Object.GetName(h) or "unnamed"
    local locName = Object.GetLocalizedName(h) or "none"
    local hx, hy, hz = Object.GetPosition(h)
    local dist_sq = 99999
    if hx and px then
        local dx = hx - px
        local dy = hy - py
        local dz = hz - pz
        dist_sq = dx*dx + dy*dy + dz*dz
    end
    log(string.format("  [%d] Handle=%s, Valid=%s, Alive=%s, Name=%s, LocalizedName=%s, DistSq=%.1f",
        i, tostring(h), tostring(valid), tostring(alive), tostring(name), tostring(locName), dist_sq))
end

return table.concat(r, "\n")
