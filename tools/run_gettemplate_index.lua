local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local mp = _MODULES.vz.MrxBootstrap.MrxPlayer
if type(mp) == "table" and mp.Hero then
    local idx = mp.__index or getmetatable(mp.Hero) and getmetatable(mp.Hero).__index
    if idx and idx.GetTemplateAndModelName then
        local ok, template, model = pcall(idx.GetTemplateAndModelName, mp.Hero)
        log(string.format("GetTemplateAndModelName => ok=%s, template=%s, model=%s",
            tostring(ok), tostring(template), tostring(model)))
    else
        log("GetTemplateAndModelName function not found in metatable index")
    end
else
    log("MrxPlayer Hero not found")
end

return table.concat(r, "\n")
