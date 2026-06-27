-- Enumerate small mystery namespaces (1-6 entries each) one level deep.
local r = {}
local function dump(ns_name, ns)
  r[#r+1] = "=== " .. ns_name .. " ==="
  if type(ns) ~= "table" then
    r[#r+1] = "  (not a table: " .. type(ns) .. ")"
    return
  end
  local keys = {}
  for k in pairs(ns) do keys[#keys+1] = tostring(k) end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local v = ns[k]
    local tv = type(v)
    local extra = ""
    if tv == "string" then extra = ' "' .. tostring(v) .. '"'
    elseif tv == "number" or tv == "boolean" then extra = " " .. tostring(v)
    end
    r[#r+1] = string.format("  %s\t%s%s", k, tv, extra)
  end
end
dump("Cheat", Cheat)
dump("Disguise", Disguise)
dump("FactionZone", FactionZone)
dump("_SYS", _SYS)
dump("Movie", Movie)
dump("Debug", Debug)
dump("Math", Math)
return table.concat(r, "\n")
