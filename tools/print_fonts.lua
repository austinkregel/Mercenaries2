local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local db_font = _MODULES.mrxguiattractmode.MrxGui.MrxGuiDialogBox._ksFont
log("DialogBox Font: " .. tostring(db_font))

local nb_font = _MODULES.mrxguiattractmode.MrxGui.MrxGuiNumericBox._ksFont
log("NumericBox Font: " .. tostring(nb_font))

local nbs_font = _MODULES.mrxguiattractmode.MrxGui.MrxGuiNumericBox._ksFontSmall
log("NumericBox Small Font: " .. tostring(nbs_font))

return table.concat(r, "\n")
