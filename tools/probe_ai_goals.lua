local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local function check_fn(name, fn)
    log(name .. " type: " .. type(fn))
    if type(fn) == "function" then
        local ok, dump = pcall(string.dump, fn)
        if ok then
            log("  Dump succeeded (Lua function)")
            local pattern = "[%w_%.%-%*%/]+"
            local found = {}
            for s in string.gmatch(dump, pattern) do
                if #s > 2 and not found[s] then
                    found[s] = true
                    log("    " .. s)
                end
            end
        else
            log("  Dump failed (C function): " .. tostring(dump))
        end
    end
end

check_fn("Ai.Goal", Ai.Goal)
check_fn("Ai.DefaultGoal", Ai.DefaultGoal)
check_fn("Ai.Squad", Ai.Squad)
check_fn("Ai.GetAttrib", Ai.GetAttrib)

return table.concat(r, "\n")
