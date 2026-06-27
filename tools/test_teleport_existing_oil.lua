local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

local target_oil = userdata and userdata("0010E1CC")
-- Wait, let's search in the active list to get the real handle object
local humans = Pg.FastCollectHumans()
for _, h in ipairs(humans) do
    if tostring(h) == "userdata: 0010E1CC" then
        target_oil = h
        break
    end
end

if not target_oil then
    -- Fallback to first Oil soldier in the list
    for _, h in ipairs(humans) do
        if h ~= lc then
            local locName = tostring(Object.GetLocalizedName(h))
            if locName == "[0x7a4c1e28]" then
                target_oil = h
                break
            end
        end
    end
end

if target_oil then
    local ox, oy, oz = Object.GetPosition(target_oil)
    log(string.format("Found Oil soldier (%s) at: %.2f, %.2f, %.2f", tostring(target_oil), ox, oy, oz))
    
    -- Teleport directly next to player
    local tx, ty, tz = px + 2, py, pz + 2
    log(string.format("Teleporting Oil soldier to: %.2f, %.2f, %.2f", tx, ty, tz))
    
    local ok_set, err_set = pcall(Object.SetPosition, target_oil, tx, ty, tz)
    log(string.format("SetPosition status: ok=%s, err=%s", tostring(ok_set), tostring(err_set)))
    
    -- Command to follow
    local tArgs = {
        AIGuid = target_oil,
        Role = "Follow",
        Target = lc,
        MinDistance = 2.0,
        MoveDistance = 4.0,
        MaxDistance = 50.0,
        Priority = "medPri"
    }
    pcall(Ai.Role, tArgs)
    
    local nx, ny, nz = Object.GetPosition(target_oil)
    log(string.format("New position: %.2f, %.2f, %.2f", nx, ny, nz))
    
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = "Oil Soldier Teleported & Commanded!",
        nPriority = 1,
        nDuration = 5
    })
else
    log("No Oil soldier found in the level!")
end

return table.concat(r, "\n")
