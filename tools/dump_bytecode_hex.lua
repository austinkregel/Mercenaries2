local fn = _MODULES.mrxguiattractmode.MrxGui.TextWidget.new
if type(fn) ~= "function" then
    return "Not a function"
end

local dump = string.dump(fn)
local hex = {}
for i = 1, #dump do
    hex[#hex+1] = string.format("%02X", string.byte(dump, i))
end
return table.concat(hex, "")
