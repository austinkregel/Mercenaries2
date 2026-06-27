-- Comprehensive Player.* probe with multi-return capture.
-- Result format per line: "OK[N] label => type=val, type=val, ..."
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

-- Setup: locals we need for chained calls
local lp = Player.GetLocalPlayer()
local char = Player.GetLocalCharacter()
r[#r+1] = "lp = " .. tostring(lp) .. " (" .. type(lp) .. ")"
r[#r+1] = "char = " .. tostring(char) .. " (" .. type(char) .. ")"

-- ===== Player.* no-arg getters =====
p("GetLocalPlayer", Player.GetLocalPlayer)
p("GetLocalCharacter", Player.GetLocalCharacter)
p("GetPrimaryPlayer", Player.GetPrimaryPlayer)
p("GetPrimaryCharacter", Player.GetPrimaryCharacter)
p("GetSecondaryPlayer", Player.GetSecondaryPlayer)
p("GetSecondaryCharacter", Player.GetSecondaryCharacter)
p("GetAnyCharacter", Player.GetAnyCharacter)
p("GetCash", Player.GetCash)
p("GetFuel", Player.GetFuel)
p("GetFuelCapacity", Player.GetFuelCapacity)
p("GetCurrentPlayers", Player.GetCurrentPlayers)
p("GetCurrentLocalPlayers", Player.GetCurrentLocalPlayers)
p("GetMaximumPlayers", Player.GetMaximumPlayers)
p("GetMaximumLocalPlayers", Player.GetMaximumLocalPlayers)
p("GetAllPlayers", Player.GetAllPlayers)
p("GetAllCharacters", Player.GetAllCharacters)
p("GetAllBoundaryGuid", Player.GetAllBoundaryGuid)
p("GetAllTargetMarkerPos", Player.GetAllTargetMarkerPos)
p("IsCoopMultiplayer", Player.IsCoopMultiplayer)
p("InCinematicMode", Player.InCinematicMode)

-- ===== Player.* taking the player handle =====
p("GetName(lp)", Player.GetName, lp)
p("GetCash(lp)", Player.GetCash, lp)
p("GetFuel(lp)", Player.GetFuel, lp)
p("GetPlayerId(lp)", Player.GetPlayerId, lp)
p("GetLocalId(lp)", Player.GetLocalId, lp)
p("GetCharacter(lp)", Player.GetCharacter, lp)
p("GetViewport(lp)", Player.GetViewport, lp)
p("GetViewportId(lp)", Player.GetViewportId, lp)
p("GetCamera(lp)", Player.GetCamera, lp)
p("GetCameraXZHeading(lp)", Player.GetCameraXZHeading, lp)
p("GetControlledObject(lp)", Player.GetControlledObject, lp)
p("GetControlBindingType(lp)", Player.GetControlBindingType, lp)
p("GetPlayerStart(lp)", Player.GetPlayerStart, lp)
p("GetRetryPosition(lp)", Player.GetRetryPosition, lp)
p("GetSeat(lp)", Player.GetSeat, lp)
p("GetTargetUnderReticle(lp)", Player.GetTargetUnderReticle, lp)
p("GetProfileCharacter(lp)", Player.GetProfileCharacter, lp)
p("GetProfileCostume(lp)", Player.GetProfileCostume, lp)
p("GetAvailableCostumes(lp)", Player.GetAvailableCostumes, lp)
p("IsJoined(lp)", Player.IsJoined, lp)
p("IsLocal(lp)", Player.IsLocal, lp)
p("IsRemote(lp)", Player.IsRemote, lp)
p("IsBoundaryDeath(lp)", Player.IsBoundaryDeath, lp)
p("GetVehicleDisguise(lp)", Player.GetVehicleDisguise, lp)
p("GetVehicleDisguiseState(lp)", Player.GetVehicleDisguiseState, lp)
return table.concat(r, "\n")
