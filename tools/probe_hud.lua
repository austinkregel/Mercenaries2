local r = {}

local function log(msg)
    r[#r+1] = tostring(msg)
end

local function dump_table(name, tbl)
    log("=== " .. name .. " ===")
    if type(tbl) ~= "table" then
        log(name .. " is not a table: " .. type(tbl))
        return
    end
    local keys = {}
    for k in pairs(tbl) do
        keys[#keys+1] = k
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
        local v = tbl[k]
        log(string.format("  %s (%s) = %s", tostring(k), type(v), tostring(v)))
    end
end

-- 1. Dump Hud.ClassyText
dump_table("Hud.ClassyText", Hud.ClassyText)

-- 2. Dump Hud.Announcement
dump_table("Hud.Announcement", Hud.Announcement)

-- 3. Check Net event types
log("=== Net Events ===")
log("Net.SendEvent_ShowMessage type: " .. type(Net.SendEvent_ShowMessage))
log("Net.SendEvent_TextFanfare type: " .. type(Net.SendEvent_TextFanfare))

return table.concat(r, "\n")
