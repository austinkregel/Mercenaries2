local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

local humans = Pg.FastCollectHumans()
local target_vz = nil

for _, h in ipairs(humans) do
    if h ~= lc then
        local locName = tostring(Object.GetLocalizedName(h))
        if locName == "[0x0f50cdf5]" then
            target_vz = h
            break
        end
    end
end

if target_vz then
    local vx, vy, vz = Object.GetPosition(target_vz)
    log(string.format("Found VZ soldier (%s) at: %.2f, %.2f, %.2f", tostring(target_vz), vx, vy, vz))
    
    -- Teleport directly in front of the player (exact height)
    local tx, ty, tz = px + 2, py, pz + 2
    log(string.format("Teleporting VZ soldier to: %.2f, %.2f, %.2f", tx, ty, tz))
    
    -- Call SetPosition
    local ok_set, err_set = pcall(Object.SetPosition, target_vz, tx, ty, tz)
    log(string.format("SetPosition status: ok=%s, err=%s", tostring(ok_set), tostring(err_set)))
    
    -- Make friendly
    pcall(Ai.SetAttitude, target_vz, lc, 3)
    pcall(Ai.SetAttitude, lc, target_vz, 3)
    
    -- Get position again immediately
    local nx, ny, nz = Object.GetPosition(target_vz)
    log(string.format("Immediate position after teleport: %.2f, %.2f, %.2f", nx, ny, nz))
else
    log("No VZ soldier found in the level to teleport!")
end

return table.concat(r, "\n")
