-- Recursively enumerate _G and every reachable string-keyed sub-table,
-- producing one `<dotted.path>\t<type>` line per entry. Sorted output
-- so diffing two runs (pre-init vs in-game, say) shows what changed.
--
-- Use:
--   py tools/lua_repl.py < tools/walk_globals.lua > all_globals.txt
--
-- Notes:
-- * Cycle detection keeps `_G._G._G...` from blowing the stack.
-- * Depth cap stays low by default. Engines like to hang giant graphs
--   off small entry points (player object -> world -> entities -> ...);
--   walking those wholesale produces megabytes of useless output. Bump
--   MAX_DEPTH if you want to chase specific namespaces deeper.
-- * Metatables are walked one level if they exist and aren't already
--   visited; that's how Pandemic-style engines usually hide engine
--   bindings behind __index on a userdata or hollow table.
-- * Only string keys are listed. Numeric-indexed arrays (positions,
--   colours, etc.) would spam without documenting anything.

local MAX_DEPTH = 4
local MAX_ENTRIES = 20000  -- hard ceiling against runaway walks

local seen = {}
local out = {}

local function record(path, v)
  if #out >= MAX_ENTRIES then return end
  out[#out+1] = path .. "\t" .. type(v)
end

local walk
walk = function(t, path, depth)
  if depth > MAX_DEPTH then return end
  if seen[t] then return end
  seen[t] = true

  for k, v in pairs(t) do
    if type(k) == "string" then
      local full = path == "" and k or (path .. "." .. k)
      record(full, v)
      local tv = type(v)
      if tv == "table" then
        walk(v, full, depth + 1)
      elseif tv == "userdata" then
        -- Engine bindings often hide behind userdata metatables
        local mt = getmetatable(v)
        if type(mt) == "table" and not seen[mt] then
          record(full .. ".<metatable>", mt)
          walk(mt, full .. ".<metatable>", depth + 1)
        end
      end
    end
  end
end

walk(_G, "", 0)

-- Sort so the output is diff-friendly and grep-friendly.
table.sort(out)

local count = #out
local truncated = (count >= MAX_ENTRIES) and " (truncated at MAX_ENTRIES)" or ""
return "entries: " .. count .. truncated .. "\n" .. table.concat(out, "\n")
