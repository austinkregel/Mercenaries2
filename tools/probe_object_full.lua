-- Comprehensive Object.* probe against the local character.
-- Result format: "OK[N] label => type=val, type=val, ..."
local r = {}
local function p(label, ...)
  local function got(ok, ...)
    if not ok then
      r[#r+1] = "ERR  " .. label .. " => " .. tostring((...))
      return
    end
    local n = select("#", ...)
    if n == 0 then
      r[#r+1] = string.format("OK[0] %s => (void)", label)
      return
    end
    local parts = {}
    for i = 1, n do
      local v = select(i, ...)
      parts[i] = string.format("%s=%s", type(v), tostring(v))
    end
    r[#r+1] = string.format("OK[%d] %s => %s", n, label, table.concat(parts, ", "))
  end
  got(pcall(...))
end

local c = Player.GetLocalCharacter()
r[#r+1] = "char = " .. tostring(c) .. " (" .. type(c) .. ")"
if not c then return table.concat(r, "\n") end

-- ===== Identity / lifecycle =====
p("IsValid(c)", Object.IsValid, c)
p("IsAlive(c)", Object.IsAlive, c)
p("IsAwake(c)", Object.IsAwake, c)
p("IsTemplate(c)", Object.IsTemplate, c)
p("IsVisible(c)", Object.IsVisible, c)
p("IsDisguised(c)", Object.IsDisguised, c)
p("IsHibernated(c)", Object.IsHibernated, c)
p("IsAttached(c)", Object.IsAttached, c)
p("IsPlayerControlled(c)", Object.IsPlayerControlled, c)
p("IsWinched(c)", Object.IsWinched, c)
p("IsWinching(c)", Object.IsWinching, c)
p("HasWinch(c)", Object.HasWinch, c)
p("InVehicle(c)", Object.InVehicle, c)
p("InSeat(c)", Object.InSeat, c)

-- ===== Names / identifiers =====
p("GetName(c)", Object.GetName, c)
p("GetLocalizedName(c)", Object.GetLocalizedName, c)
p("GetModelName(c)", Object.GetModelName, c)

-- ===== Health / damage =====
p("GetHealth(c)", Object.GetHealth, c)
p("GetMaxHealth(c)", Object.GetMaxHealth, c)
p("GetNodeHealth(c)", Object.GetNodeHealth, c)
p("GetInvincible(c)", Object.GetInvincible, c)

-- ===== Spatial =====
p("GetPosition(c)", Object.GetPosition, c)
p("GetYaw(c)", Object.GetYaw, c)
p("GetMass(c)", Object.GetMass, c)
p("GetHeightAboveTerrain(c)", Object.GetHeightAboveTerrain, c)
p("GetHibernationDistance(c)", Object.GetHibernationDistance, c)
p("GetVelocity(c)", Object.GetVelocity, c)
p("GetVelocitySquared(c)", Object.GetVelocitySquared, c)
p("GetVelocityVector(c)", Object.GetVelocityVector, c)
p("GetPhysicsType(c)", Object.GetPhysicsType, c)

-- ===== Hardpoint (likely turrets / attachment points) =====
p("GetHardpointPosition(c)", Object.GetHardpointPosition, c)
p("GetHardpointPitch(c)", Object.GetHardpointPitch, c)
p("GetHardpointYaw(c)", Object.GetHardpointYaw, c)

-- ===== Hierarchy / attachments =====
p("GetParent(c)", Object.GetParent, c)
p("GetAttachedObjects(c)", Object.GetAttachedObjects, c)
p("GetWinchState(c)", Object.GetWinchState, c)

-- ===== Misc value queries =====
p("GetCashValue(c)", Object.GetCashValue, c)
p("HasLabel(c, 'player')", Object.HasLabel, c, "player")
p("InsideBoundary(c)", Object.InsideBoundary, c)
p("OutsideBoundary(c)", Object.OutsideBoundary, c)
return table.concat(r, "\n")
