local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local ok, err = pcall(dofile, "C:/Games/Mercenaries 2 World in Flames/gamemode_wave_defense.lua")
log("dofile status: " .. tostring(ok) .. ", err=" .. tostring(err))

return table.concat(r, "\n")
