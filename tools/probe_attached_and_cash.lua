-- Probe the player's attached objects + verify the cash mutator pattern.
local r = {}
local function multi(ok, ...)
  if not ok then return "ERR " .. tostring((...)) end
  local n = select("#", ...)
  if n == 0 then return "(void)" end
  local p = {}
  for i = 1, n do
    local v = select(i, ...)
    p[i] = string.format("%s=%s", type(v), tostring(v))
  end
  return string.format("[%d] %s", n, table.concat(p, ", "))
end
local function p(label, ...)
  r[#r+1] = label .. " => " .. multi(pcall(...))
end

local c = Player.GetLocalCharacter()
r[#r+1] = "char = " .. tostring(c)

-- ===== 1. Walk attached objects =====
local atts = Object.GetAttachedObjects(c)
r[#r+1] = ""
r[#r+1] = "=== attached objects (Object.GetAttachedObjects) ==="
if type(atts) == "table" then
  -- Sort by key to make output stable.
  local keys = {}
  for k in pairs(atts) do keys[#keys+1] = k end
  table.sort(keys)
  for _, k in ipairs(keys) do
    local obj = atts[k]
    r[#r+1] = string.format("--- atts[%s] = %s ---", tostring(k), tostring(obj))
    p("  IsValid", Object.IsValid, obj)
    p("  GetName", Object.GetName, obj)
    p("  GetLocalizedName", Object.GetLocalizedName, obj)
    p("  GetModelName", Object.GetModelName, obj)
    p("  GetPhysicsType", Object.GetPhysicsType, obj)
    p("  GetHealth", Object.GetHealth, obj)
    p("  IsVisible", Object.IsVisible, obj)
    -- Try Weapon-namespace calls — if it's a weapon they should work
    p("  Weapon.IsPrimary", Weapon.IsPrimary, obj)
    p("  Weapon.GetClipAmmo", Weapon.GetClipAmmo, obj)
    p("  Weapon.GetReserveAmmo", Weapon.GetReserveAmmo, obj)
    p("  Weapon.GetMaxClipAmmo", Weapon.GetMaxClipAmmo, obj)
    p("  Weapon.IsDesignator", Weapon.IsDesignator, obj)
  end
else
  r[#r+1] = "  (not a table: " .. type(atts) .. ")"
end

-- ===== 2. Cash mutator end-to-end =====
r[#r+1] = ""
r[#r+1] = "=== cash mutator test ==="
local before = Player.GetCash()
r[#r+1] = "before:                 " .. tostring(before)
p("Player.AddCash(1) returns", Player.AddCash, 1)
local after_add = Player.GetCash()
r[#r+1] = "after AddCash(1):       " .. tostring(after_add) ..
          " (delta " .. tostring(after_add - before) .. ")"
p("Player.AddCash(-1) returns", Player.AddCash, -1)
local after_revert = Player.GetCash()
r[#r+1] = "after AddCash(-1):      " .. tostring(after_revert) ..
          " (delta from start " .. tostring(after_revert - before) .. ")"
return table.concat(r, "\n")
