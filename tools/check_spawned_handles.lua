local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local function check(handle_str, h)
    log("Checking handle: " .. handle_str)
    if h then
        log("  Type: " .. type(h))
        log("  IsValid: " .. tostring(Object.IsValid(h)))
        log("  IsAlive: " .. tostring(Object.IsAlive(h)))
        local px, py, pz = Object.GetPosition(h)
        if px then
            log(string.format("  Position: %.2f, %.2f, %.2f", px, py, pz))
        end
    else
        log("  Handle is nil")
    end
end

-- Try checking both handles
local h1 = userdata and userdata("40014917") -- wait, in Lua, how do we convert string back to userdata?
-- We can just do a sweep over all humans and find the ones that are not the player!
local lc = Player.GetLocalCharacter()
local humans = Pg.FastCollectHumans()
for i, h in ipairs(humans) do
    if h ~= lc then
        check("Human #" .. i .. " (" .. tostring(h) .. ")", h)
    end
end

return table.concat(r, "\n")
