-- Dump the global table from the captured lua_State. Pipe through the REPL:
--   py tools/lua_repl.py < tools/enum_globals.lua > globals.txt
--
-- Skips numeric-indexed values to avoid spam. Lines come out as
-- `<type>\t<name>` so you can grep:
--   grep -i 'function\s\+.*\(cheat\|debug\|menu\|skip\)' globals.txt
--
-- The bridge concatenates returned values with tabs and sends one line per
-- chunk. To keep this manageable for the bridge buffer, we accumulate into
-- a local string and return it once.
local out = {}
for k, v in pairs(_G) do
  if type(k) == "string" then
    out[#out+1] = type(v) .. "\t" .. k
  end
end
table.sort(out)
return table.concat(out, "\n")
