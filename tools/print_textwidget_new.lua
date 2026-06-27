local new_fn = _MODULES.mrxguiattractmode.MrxGui.TextWidget.new
local ok, widget = pcall(new_fn, {})
if ok then
    local keys = {}
    for k, v in pairs(widget) do
        keys[#keys+1] = string.format("%s = %s (%s)", tostring(k), tostring(v), type(v))
    end
    return "Widget keys:\n" .. table.concat(keys, "\n")
else
    return "Failed: " .. tostring(widget)
end
