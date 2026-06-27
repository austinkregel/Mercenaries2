local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

local humans = Pg.FastCollectHumans()
local spawned_vz = nil

for _, h in ipairs(humans) do
    if h ~= lc then
        local locName = tostring(Object.GetLocalizedName(h))
        if locName == "[0x0f50cdf5]" then
            spawned_vz = h
            break
        end
    end
end

if spawned_vz then
    log("Found spawned VZ soldier: " .. tostring(spawned_vz))
    
    -- 1. Teleport them directly in front of the player (exact height)
    local tx, ty, tz = px + 2, py, pz + 2
    log(string.format("Teleporting VZ soldier to: %.2f, %.2f, %.2f", tx, ty, tz))
    pcall(Object.SetPosition, spawned_vz, tx, ty, tz)
    
    -- 2. Make them friendly to the player (attitude 3 = Friendly)
    pcall(Ai.SetAttitude, spawned_vz, lc, 3)
    pcall(Ai.SetAttitude, lc, spawned_vz, 3)
    log("Set attitude to Friendly (3)")
    
    -- 3. Command them to follow the player
    local tArgs = {
        AIGuid = spawned_vz,
        Role = "Follow",
        Target = lc,
        MinDistance = 2.0,
        MoveDistance = 4.0,
        MaxDistance = 50.0,
        Priority = "medPri"
    }
    local ok_role, err_role = pcall(Ai.Role, tArgs)
    log(string.format("Ai.Role => ok=%s, err=%s", tostring(ok_role), tostring(err_role)))
    
    if ok_role then
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "VZ Soldier Teleported & Commanded to Follow!",
            nPriority = 1,
            nDuration = 5
        })
    end
else
    log("No spawned VZ soldier found in the active list.")
end

return table.concat(r, "\n")
