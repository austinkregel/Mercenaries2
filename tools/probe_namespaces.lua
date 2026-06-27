-- Look one level deep into common namespaces. Many engines stash dev
-- functions inside tables like Debug, Cheats, Game, Console, etc. If any
-- of these exist as globals, enumerate their fields too.
local probe = { "Debug", "Cheats", "Cheat", "Game", "Console", "Dev",
                "Menu", "UI", "Mission", "DebugMenu" }
local out = {}
for _, name in ipairs(probe) do
  local v = rawget(_G, name)
  if type(v) == "table" then
    out[#out+1] = "== " .. name .. " (table) =="
    for k2, v2 in pairs(v) do
      out[#out+1] = "  " .. type(v2) .. "\t" .. name .. "." .. tostring(k2)
    end
  elseif v ~= nil then
    out[#out+1] = "== " .. name .. " (" .. type(v) .. ") =="
  end
end
if #out == 0 then return "no candidate namespaces found in _G" end
return table.concat(out, "\n")
