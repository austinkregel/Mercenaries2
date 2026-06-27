local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local new_fn = _MODULES.mrxguiattractmode.MrxGui.TextWidget.new

local ok1, err1 = pcall(new_fn)
log(string.format("new() => ok=%s, err=%s", tostring(ok1), tostring(err1)))

local ok2, err2 = pcall(new_fn, {})
log(string.format("new({}) => ok=%s, err=%s", tostring(ok2), tostring(err2)))

local ok3, err3 = pcall(new_fn, {}, {})
log(string.format("new({}, {}) => ok=%s, err=%s", tostring(ok3), tostring(err3)))

return table.concat(r, "\n")
