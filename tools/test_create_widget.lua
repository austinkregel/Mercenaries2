local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local ok1, err1 = pcall(_GuiInternal.CreateTextWidget)
log(string.format("CreateTextWidget() => ok=%s, err=%s", tostring(ok1), tostring(err1)))

local ok2, err2 = pcall(_GuiInternal.CreateTextWidget, "test")
log(string.format("CreateTextWidget('test') => ok=%s, err=%s", tostring(ok2), tostring(err2)))

return table.concat(r, "\n")
