local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
log(string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz))

local humans = Pg.FastCollectHumans()
log("Humans count: " .. #humans)

return table.concat(r, "\n")
