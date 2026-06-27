local r = {}
local function p(label, fn)
  local ok, val = pcall(fn)
  r[#r+1] = string.format("%s\t%s\t%s",
    ok and "OK" or "ERR", label, tostring(val))
end

local char = Player.GetLocalCharacter()
r[#r+1] = "char = " .. tostring(char) .. " (" .. type(char) .. ")"

if char then
  p("Object.IsValid(char)", function() return Object.IsValid(char) end)
  p("Object.IsAlive(char)", function() return Object.IsAlive(char) end)
  p("Object.GetName(char)", function() return Object.GetName(char) end)
  p("Object.GetLocalizedName(char)", function() return Object.GetLocalizedName(char) end)
  p("Object.GetHealth(char)", function() return Object.GetHealth(char) end)
  p("Object.GetMaxHealth(char)", function() return Object.GetMaxHealth(char) end)
  p("Object.GetPosition(char)", function() return Object.GetPosition(char) end)
  p("Object.GetYaw(char)", function() return Object.GetYaw(char) end)
  p("Object.GetMass(char)", function() return Object.GetMass(char) end)
  p("Object.GetModelName(char)", function() return Object.GetModelName(char) end)
  p("Object.GetVelocity(char)", function() return Object.GetVelocity(char) end)
  p("Object.GetVelocityVector(char)", function() return Object.GetVelocityVector(char) end)
  p("Object.GetHeightAboveTerrain(char)", function() return Object.GetHeightAboveTerrain(char) end)
  p("Object.IsAwake(char)", function() return Object.IsAwake(char) end)
  p("Object.InVehicle(char)", function() return Object.InVehicle(char) end)
  p("Object.IsPlayerControlled(char)", function() return Object.IsPlayerControlled(char) end)
  p("Object.GetInvincible(char)", function() return Object.GetInvincible(char) end)
  p("Object.GetParent(char)", function() return Object.GetParent(char) end)
end
return table.concat(r, "\n")
