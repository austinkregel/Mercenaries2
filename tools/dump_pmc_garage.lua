local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local function dump_consts(name, fn)
    if type(fn) ~= "function" then
        log(name .. " is not a function")
        return
    end
    local ok, dump = pcall(string.dump, fn)
    if not ok then
        log("Cannot dump " .. name .. ": " .. tostring(dump))
        return
    end
    log("=== Constants in " .. name .. " ===")
    local pattern = "[%w_%.%-%*%/]+"
    local found = {}
    for s in string.gmatch(dump, pattern) do
        if #s > 2 and not found[s] then
            found[s] = true
            log("  " .. s)
        end
    end
end

dump_consts("_SpawnVehicle", _MODULES.wifpmcgarage._SpawnVehicle)
dump_consts("_SpawnVehicleFromData", _MODULES.wifpmcgarage._SpawnVehicleFromData)

return table.concat(r, "\n")
