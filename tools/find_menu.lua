-- Triage candidate Cheat Menu openers without dumping the whole _G.
-- Pipe through the REPL:  py tools/lua_repl.py < tools/find_menu.lua
local hits = {}
local patterns = {
  "cheat", "debug", "menu", "skip", "mission",
  "hierarchy", "traverse", "spawn", "give", "unlock",
}
for k, v in pairs(_G) do
  if type(k) == "string" and type(v) == "function" then
    local lk = k:lower()
    for _, p in ipairs(patterns) do
      if lk:find(p, 1, true) then
        hits[#hits+1] = k
        break
      end
    end
  end
end
table.sort(hits)
return "matches: " .. #hits .. "\n" .. table.concat(hits, "\n")
