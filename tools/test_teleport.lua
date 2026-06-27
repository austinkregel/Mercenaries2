local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
log(string.format("Original Player Position: %.2f, %.2f, %.2f", px, py, pz))

local humans = Pg.FastCollectHumans()
local target_human = nil

for i, h in ipairs(humans) do
    if h ~= lc then
        target_human = h
        break
    end
end

if target_human then
    local tx, ty, tz = Object.GetPosition(target_human)
    log(string.format("Found target human (%s) at: %.2f, %.2f, %.2f", tostring(target_human), tx, ty, tz))
    
    -- Teleport player directly to target human (slightly offset to not clip)
    local ok, err = pcall(Object.SetPosition, lc, tx, ty + 1.0, tz + 1.0)
    log(string.format("Teleporting player to target... ok=%s, err=%s", tostring(ok), tostring(err)))
    
    local nx, ny, nz = Object.GetPosition(lc)
    log(string.format("New Player Position: %.2f, %.2f, %.2f", nx, ny, nz))
else
    log("No other humans found to teleport to!")
end

return table.concat(r, "\n")
