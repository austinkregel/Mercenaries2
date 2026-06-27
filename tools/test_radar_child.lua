local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local radar_tbl = _MODULES.mrxguihudradar.oParent
if type(radar_tbl) ~= "table" then
    return "Radar parent table not found"
end

local radar_uId = radar_tbl.BasicData.uId
log("Radar Parent uId: " .. tostring(radar_uId))

local tw_class = _MODULES.mrxguiattractmode.MrxGui.TextWidget
local ok, widget = pcall(tw_class.new, tw_class, {})
if not ok then
    return "Failed to create widget: " .. tostring(widget)
end

local widget_uId = widget.BasicData.uId
log("Widget uId: " .. tostring(widget_uId))

-- Add as child of radar parent
local ok_add, err_add = pcall(_GuiInternal.AddWidgetChild, radar_uId, widget_uId)
log(string.format("AddWidgetChild => ok=%s, err=%s", tostring(ok_add), tostring(err_add)))

-- Customize and display
widget:SetText("LUA BRIDGE ACTIVE")
widget:SetFont("font_16")
widget:SetScale(1.5)
widget:SetLocation(50, -50) -- slightly right and above the radar
widget:SetColor(0, 255, 0, 255) -- bright green!
widget:SetVisible(true)

-- Persist globally
_G.AntigravityRadarText = widget

return table.concat(r, "\n")
