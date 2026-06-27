local fn = _MODULES.mrxguiattractmode.MrxGui.TextWidget.new
if type(fn) == "function" then
    local dump = string.dump(fn)
    local f = io.open("C:\\Users\\logan\\source\\repos\\Merc2Reborn\\out\\textwidget_new.bc", "wb")
    if f then
        f:write(dump)
        f:close()
        return "Saved successfully"
    else
        return "Failed to open file"
    end
else
    return "Not a function"
end
