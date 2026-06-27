local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local function check_widget(name, tbl)
    if type(tbl) ~= "table" then
        log(name .. " is not a table")
        return
    end
    if tbl.BasicData and tbl.BasicData.uId then
        log(string.format("%s uId = %s (type=%s, text=%s)", name, tostring(tbl.BasicData.uId), tostring(tbl.BasicData.type), tostring(tbl.BasicData.text)))
    else
        log(name .. " has no BasicData.uId")
    end
end

check_widget("radar.oParent", _MODULES.mrxguihudradar.oParent)
check_widget("radar.oRadarObject", _MODULES.mrxguihudradar.oRadarObject)
check_widget("ammocountersnew.oChild", _MODULES.mrxguihudammocountersnew.oChild)
check_widget("ammocountersnew.ParentWidget", _MODULES.mrxguihudammocountersnew.oChild and _MODULES.mrxguihudammocountersnew.oChild.ParentWidget)

-- Let's also look at mrxguihudhealthcounter
local hc = _MODULES.mrxguihudhealthcounter
if type(hc) == "table" then
    for k, v in pairs(hc) do
        if type(v) == "table" and v.BasicData then
            check_widget("healthcounter." .. tostring(k), v)
        end
    end
end

return table.concat(r, "\n")
