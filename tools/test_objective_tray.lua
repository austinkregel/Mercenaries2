local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local ok1, err1 = pcall(Hud.ObjectiveTray.SetSlotToText, Hud.ObjectiveTray, 0, "Antigravity Active", true)
log(string.format("SetSlotToText(0, ...) => ok=%s, err=%s", tostring(ok1), tostring(err1)))

local ok2, err2 = pcall(Hud.ObjectiveTray.SetSlotToText, Hud.ObjectiveTray, 1, "Explore custom UI elements", true)
log(string.format("SetSlotToText(1, ...) => ok=%s, err=%s", tostring(ok2), tostring(err2)))

return table.concat(r, "\n")
