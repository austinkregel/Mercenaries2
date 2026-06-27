local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)

local humans = Pg.FastCollectHumans()
local target = nil
local min_dist = 9999999
for _, h in ipairs(humans) do
    if h ~= lc and Object.IsValid(h) and Object.IsAlive(h) then
        local hx, hy, hz = Object.GetPosition(h)
        if hx then
            local dist = (hx-px)*(hx-px) + (hy-py)*(hy-py) + (hz-pz)*(hz-pz)
            if dist < min_dist then
                min_dist = dist
                target = h
            end
        end
    end
end

if not target then
    return "No AI target found to query!"
end

log("Target NPC: " .. tostring(target))

-- 1. Ai.GetState
local ok1, val1 = pcall(Ai.GetState, target)
log(string.format("Ai.GetState => ok=%s, val=%s", tostring(ok1), tostring(val1)))

-- 2. Ai.GetFeeling
local ok2, val2 = pcall(Ai.GetFeeling, target)
log(string.format("Ai.GetFeeling => ok=%s, val=%s", tostring(ok2), tostring(val2)))

-- 3. Ai.GetPerceivability
local ok3, val3 = pcall(Ai.GetPerceivability, target)
log(string.format("Ai.GetPerceivability => ok=%s, val=%s", tostring(ok3), tostring(val3)))

-- 4. Ai.Squad
local ok4, val4 = pcall(Ai.Squad, target)
log(string.format("Ai.Squad => ok=%s, val=%s", tostring(ok4), tostring(val4)))

-- 5. Object.IsPlayerControlled
local ok5, val5 = pcall(Object.IsPlayerControlled, target)
log(string.format("Object.IsPlayerControlled => ok=%s, val=%s", tostring(ok5), tostring(val5)))

return table.concat(r, "\n")
