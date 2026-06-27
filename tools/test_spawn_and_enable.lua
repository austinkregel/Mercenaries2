local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
local yaw = Object.GetYaw(lc)

-- 1. Spawn a new VZ soldier
local ok, h = pcall(Pg.Spawn, "VZ", px, py, pz, yaw)
if not ok or not h then
    return "Spawn failed: " .. tostring(h)
end
log("Spawned soldier: " .. tostring(h))

-- 2. Call Ai.Enable
local ok_en, err_en = pcall(Ai.Enable, h)
log(string.format("Ai.Enable => ok=%s, err=%s", tostring(ok_en), tostring(err_en)))

-- 3. Check if they are now in the active list
local humans = Pg.FastCollectHumans()
local found = false
for _, human in ipairs(humans) do
    if human == h then
        found = true
        break
    end
end
log("Found in FastCollectHumans active list: " .. tostring(found))

if found then
    local status = "Successfully spawned and activated VZ soldier!"
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = status,
        nPriority = 1,
        nDuration = 5
    })
end

return table.concat(r, "\n")
