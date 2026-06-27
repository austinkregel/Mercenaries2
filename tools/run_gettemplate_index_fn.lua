local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local mp = _MODULES.vz.MrxBootstrap.MrxPlayer
if type(mp) == "table" and mp.Hero then
    local idx = mp.__index
    if type(idx) == "function" then
        local fn = idx(mp.Hero, "GetTemplateAndModelName")
        log("Lookup result type: " .. type(fn))
        if type(fn) == "function" then
            local ok, template, model = pcall(fn, mp.Hero)
            log(string.format("GetTemplateAndModelName => ok=%s, template=%s, model=%s",
                tostring(ok), tostring(template), tostring(model)))
        end
    else
        log("__index is not a function: " .. type(idx))
    end
else
    log("MrxPlayer Hero not found")
end

return table.concat(r, "\n")
