local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

if _G.MyTickLogs then
    log("=== Tick Logs ===")
    for i, v in ipairs(_G.MyTickLogs) do
        log(string.format("  [%d] %s", i, tostring(v)))
    end
else
    log("MyTickLogs is nil (ticks didn't run or weren't stored)")
end

return table.concat(r, "\n")
