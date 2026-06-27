local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()
local vp = Player.GetViewportId(lp)
log("Viewport ID: " .. tostring(vp))

local tw_class = _MODULES.mrxguiattractmode.MrxGui.TextWidget
local ok, widget = pcall(tw_class.new, tw_class, {})
if not ok then
    return "Failed to create widget: " .. tostring(widget)
end

local widget_uId = widget.BasicData.uId
log("Widget uId: " .. tostring(widget_uId))

-- Test AddWidgetChild
local ok_add, err_add = pcall(_GuiInternal.AddWidgetChild, vp, widget_uId)
log(string.format("AddWidgetChild(vp, widget_uId) => ok=%s, err=%s", tostring(ok_add), tostring(err_add)))

-- Customize and enable
pcall(widget.SetText, widget, "Antigravity Custom UI Active")
pcall(widget.SetFont, widget, "font_16")
pcall(widget.SetScale, widget, 3.0)
pcall(widget.SetLocation, widget, 400, 300)
pcall(widget.SetColor, widget, 255, 0, 0, 255)
pcall(widget.SetVisible, widget, true)

-- Persist
_G.AntigravityTestWidget2 = widget

return table.concat(r, "\n")
