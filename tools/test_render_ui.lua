local tw_class = _MODULES.mrxguiattractmode.MrxGui.TextWidget
if type(tw_class) ~= "table" then
    return "TextWidget class not found"
end

local ok, widget = pcall(tw_class.new, tw_class, {})
if not ok then
    return "Failed to instantiate TextWidget: " .. tostring(widget)
end

-- Customize the widget
pcall(widget.SetText, widget, "Antigravity Custom UI Active")
pcall(widget.SetFont, widget, "font_16")
pcall(widget.SetScale, widget, 2.0)
pcall(widget.SetLocation, widget, 300, 300)
pcall(widget.SetColor, widget, 255, 0, 0, 255)
pcall(widget.SetVisible, widget, true)

-- Keep a global reference to prevent GC from freeing it
_G.AntigravityTestWidget = widget

local keys = {}
for k, v in pairs(widget.BasicData) do
    keys[#keys+1] = string.format("%s = %s", tostring(k), tostring(v))
end

return "Widget created successfully!\n" .. table.concat(keys, "\n")
