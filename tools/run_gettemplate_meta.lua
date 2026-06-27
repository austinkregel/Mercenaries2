local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local mp = _MODULES.vz.MrxBootstrap.MrxPlayer
if type(mp) == "table" and mp.Hero then
    local mt = getmetatable(mp.Hero)
    if mt and mt.__index then
        log("Metatable __index type: " .. type(mt.__index))
        local fn = mt.__index(mp.Hero, "GetTemplateAndModelName")
        log("Lookup result type: " .. type(fn))
        if type(fn) == "function" then
            local ok, template, model = pcall(fn, mp.Hero)
            log(string.format("GetTemplateAndModelName => ok=%s, template=%s, model=%s",
                tostring(ok), tostring(template), tostring(model)))
        end
    else
        log("Metatable or __index not found")
    end
else
    log("MrxPlayer Hero not found")
end

return table.concat(r, "\n")
