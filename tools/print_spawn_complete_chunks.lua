local fn = _MODULES.mrxsupportdelivery.MrxUtil._SpawnActorComplete
if type(fn) ~= "function" then
    return "Not a function"
end

local dump = string.dump(fn)
local hex = {}
for i = 1, #dump do
    hex[#hex+1] = string.format("%02X", string.byte(dump, i))
end
local full_hex = table.concat(hex, "")

local r = {}
local chunk_size = 100
for i = 1, #full_hex, chunk_size do
    r[#r+1] = string.sub(full_hex, i, i + chunk_size - 1)
end
return table.concat(r, "\n")
