local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local ok, humans = pcall(Pg.FastCollectHumans)
if ok and type(humans) == "table" then
    log("Total humans: " .. #humans)
    for i, h in ipairs(humans) do
        local name = Object.GetName(h) or "none"
        local locName = Object.GetLocalizedName(h) or "none"
        local model = Object.GetModelName(h)
        local model_str = model and tostring(model) or "none"
        log(string.format("  [%d] Handle=%s, Name=%s, LocalizedName=%s, Model=%s",
            i, tostring(h), tostring(name), tostring(locName), model_str))
    end
else
    log("Failed to collect humans: " .. tostring(humans))
end

return table.concat(r, "\n")
