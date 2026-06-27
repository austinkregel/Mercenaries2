local r = {}

local function log(msg)
    r[#r+1] = tostring(msg)
end

for i = 0, 5 do
    local ok, val = pcall(Player.GetAllCharacters, i)
    log(string.format("GetAllCharacters(%d) => ok=%s, val=%s", i, tostring(ok), tostring(val)))
end

return table.concat(r, "\n")
