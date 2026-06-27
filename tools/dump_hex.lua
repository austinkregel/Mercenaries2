local dump = string.dump(Hud.ClassyText.ShowText)
local hex = {}
for i = 1, string.len(dump) do
    hex[#hex+1] = string.format("%02X", string.byte(dump, i))
end
return table.concat(hex)
