local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local mp = _MODULES.vz.MrxBootstrap.MrxPlayer
local fn = mp.GetTemplateAndModelName

local function try_call(desc, ...)
    local ok, a, b = pcall(fn, ...)
    log(string.format("%s => ok=%s, ret1=%s, ret2=%s", desc, tostring(ok), tostring(a), tostring(b)))
end

try_call("No args", nil)
try_call("With mp", mp)
try_call("With Hero", mp.Hero)
try_call("With mp, 1", mp, 1)
try_call("With mp, 1, 1", mp, 1, 1)

return table.concat(r, "\n")
