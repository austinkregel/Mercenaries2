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

local uId = widget.BasicData.uId
log("Widget uId: " .. tostring(uId))

-- Add to fullscreen viewport
local ok_add, err_add = pcall(_GuiInternal.AddWidgetChild, vp, uId)
log(string.format("AddWidgetChild => ok=%s, err=%s", tostring(ok_add), tostring(err_add)))

-- Customize using english_18 font
pcall(_GuiInternal.SetTextFont, uId, "english_18")
pcall(_GuiInternal.SetTextText, uId, "Antigravity Custom UI Active")
pcall(_GuiInternal.SetTextScale, uId, 3.0)
pcall(_GuiInternal.SetWidgetLocation, uId, 500, 500)
pcall(_GuiInternal.SetWidgetColor, uId, 255, 0, 0, 255, false)
pcall(_GuiInternal.SetWidgetVisible, uId, true)

-- Persist
_G.AntigravityFullscreenText = widget

return table.concat(r, "\n")
