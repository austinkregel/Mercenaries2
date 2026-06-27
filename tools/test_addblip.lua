local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local ok1, err1 = pcall(Pda.Map.AddBlip)
log(string.format("AddBlip() => ok=%s, err=%s", tostring(ok1), tostring(err1)))

local ok2, err2 = pcall(Pda.Map.AddBlip, "test")
log(string.format("AddBlip('test') => ok=%s, err=%s", tostring(ok2), tostring(err2)))

return table.concat(r, "\n")
