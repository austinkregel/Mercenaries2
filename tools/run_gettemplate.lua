local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local mp = _MODULES.vz.MrxBootstrap.MrxPlayer
if type(mp) == "table" and mp.Hero then
    local ok, template, model = pcall(mp.Hero.GetTemplateAndModelName, mp.Hero)
    log(string.format("Hero:GetTemplateAndModelName() => ok=%s, template=%s, model=%s",
        tostring(ok), tostring(template), tostring(model)))
else
    log("MrxPlayer Hero not found")
end

return table.concat(r, "\n")
