local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local pyaw = Object.GetYaw(lc)

-- Calculate spawn position 5 meters in front of the player
-- (using simple yaw trigonometry: x = px + 5 * cos(yaw), z = pz + 5 * sin(yaw))
-- Since yaw is 0 along X/Z, let's just spawn at px + 5, py, pz + 5
local sx = px + 5
local sy = py
local sz = pz + 5

local function try_spawn(template)
    local ok, h = pcall(Pg.Spawn, template, sx, sy, sz, pyaw)
    if ok and h then
        log(string.format("Spawn('%s') => SUCCESS: Handle=%s, Valid=%s, Alive=%s",
            template, tostring(h), tostring(Object.IsValid(h)), tostring(Object.IsAlive(h))))
        -- If spawned, set a name so we can identify it
        pcall(Object.SetName, h, "Spawned_" .. template)
    else
        log(string.format("Spawn('%s') => FAILED: %s", template, tostring(h)))
    end
end

try_spawn("VZ")
try_spawn("Allied")
try_spawn("Civ")

return table.concat(r, "\n")
