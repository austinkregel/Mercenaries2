local r = {}

local function log(msg)
    r[#r+1] = tostring(msg)
end

local c1 = Player.GetAllCharacters()
log("First char: " .. tostring(c1))

if c1 then
    local c2 = Player.GetAllCharacters(c1)
    log("Second char: " .. tostring(c2))
    if c2 then
        local c3 = Player.GetAllCharacters(c2)
        log("Third char: " .. tostring(c3))
    end
end

return table.concat(r, "\n")
