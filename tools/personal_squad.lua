local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)

local humans = Pg.FastCollectHumans()
local squad = {}

for _, h in ipairs(humans) do
    if h ~= lc and Object.IsValid(h) and Object.IsAlive(h) then
        local hx, hy, hz = Object.GetPosition(h)
        if hx then
            local dist = (hx-px)*(hx-px) + (hy-py)*(hy-py) + (hz-pz)*(hz-pz)
            squad[#squad+1] = { handle = h, dist_sq = dist }
        end
    end
end

-- Sort by distance
table.sort(squad, function(a, b) return a.dist_sq < b.dist_sq end)

local recruited_count = 0
for i = 1, math.min(3, #squad) do
    local target = squad[i].handle
    local tArgs = {
        AIGuid = target,
        Role = "Follow",
        Target = lc,
        MinDistance = 3.0,
        MoveDistance = 5.0,
        MaxDistance = 50.0,
        Priority = "medPri"
    }
    local ok, err = pcall(Ai.Role, tArgs)
    if ok and err == 1 then
        recruited_count = recruited_count + 1
        log(string.format("Recruited NPC %d (%s) to follow", i, tostring(target)))
    else
        log(string.format("Failed to recruit NPC %d: %s", i, tostring(err)))
    end
end

if recruited_count > 0 then
    local status = string.format("RECRUITED %d GUARDS INTO YOUR SQUAD!", recruited_count)
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = status,
        nPriority = 1,
        nDuration = 6
    })
else
    log("No guards recruited.")
end

return table.concat(r, "\n")
