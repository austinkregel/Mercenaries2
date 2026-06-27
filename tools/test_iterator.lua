local r = {}

local function log(msg)
    r[#r+1] = tostring(msg)
end

local it = Player.GetAllCharacters()
log("Iterator type: " .. type(it))
log("Iterator value: " .. tostring(it))

local mt = getmetatable(it)
log("Metatable type: " .. type(mt))
if type(mt) == "table" then
    for k, v in pairs(mt) do
        log(string.format("  mt[%s] = %s (%s)", tostring(k), tostring(v), type(v)))
    end
else
    log("Metatable is not a table")
end

return table.concat(r, "\n")
