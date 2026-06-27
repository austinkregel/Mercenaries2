local lc = Player.GetLocalCharacter()
local px, py, pz = Object.GetPosition(lc)
return string.format("Player Position: %.2f, %.2f, %.2f", px, py, pz)
