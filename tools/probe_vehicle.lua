local r = {}

local function log(msg)
    r[#r+1] = tostring(msg)
end

local function test_call(label, fn, ...)
    local function got(ok, ...)
        if not ok then
            log(string.format("ERR  %s => %s", label, tostring((...))))
            return
        end
        local n = select("#", ...)
        if n == 0 then
            log(string.format("OK[0] %s => (void)", label))
            return
        end
        local parts = {}
        for i = 1, n do
            local v = select(i, ...)
            parts[i] = string.format("%s=%s", type(v), tostring(v))
        end
        log(string.format("OK[%d] %s => %s", n, label, table.concat(parts, ", ")))
    end
    got(pcall(fn, ...))
end

local lp = Player.GetLocalPlayer()
local lc = Player.GetLocalCharacter()

if not lc then
    return "No local character found"
end

local veh, seat = Object.InVehicle(lc)
if not veh then
    pcall(Hud.ClassyText.ShowText, Hud.ClassyText, {
        sText = "Please enter a vehicle!",
        nDuration = 5
    })
    return "PLAYER_NOT_IN_VEHICLE"
end

log(string.format("Character in vehicle: %s, seat index: %s", tostring(veh), tostring(seat)))

-- Object-level queries on vehicle
test_call("Object.IsValid(veh)", Object.IsValid, veh)
test_call("Object.GetName(veh)", Object.GetName, veh)
test_call("Object.GetLocalizedName(veh)", Object.GetLocalizedName, veh)
test_call("Object.GetModelName(veh)", Object.GetModelName, veh)
test_call("Object.GetHealth(veh)", Object.GetHealth, veh)
test_call("Object.GetMaxHealth(veh)", Object.GetMaxHealth, veh)
test_call("Object.GetPhysicsType(veh)", Object.GetPhysicsType, veh)
test_call("Object.GetPosition(veh)", Object.GetPosition, veh)

-- Vehicle namespace queries
test_call("Vehicle.IsFlipped(veh)", Vehicle.IsFlipped, veh)
test_call("Vehicle.IsFlying(veh)", Vehicle.IsFlying, veh)
test_call("Vehicle.GetDriver(veh)", Vehicle.GetDriver, veh)
test_call("Vehicle.GetRiders(veh)", Vehicle.GetRiders, veh)
test_call("Vehicle.RestoreHealth(veh)", Vehicle.RestoreHealth, veh)
test_call("Vehicle.RestoreAmmo(veh)", Vehicle.RestoreAmmo, veh)

-- Seat / door queries
test_call("Vehicle.GetSeatParams(veh)", Vehicle.GetSeatParams, veh)
test_call("Vehicle.GetSeatParams(veh, 0)", Vehicle.GetSeatParams, veh, 0)
test_call("Vehicle.GetSeatByType(veh)", Vehicle.GetSeatByType, veh)
test_call("Vehicle.GetSeatByType(veh, 0)", Vehicle.GetSeatByType, veh, 0)
test_call("Vehicle.OpenDoor(veh)", Vehicle.OpenDoor, veh)
test_call("Vehicle.OpenDoor(veh, 0)", Vehicle.OpenDoor, veh, 0)
test_call("Vehicle.CloseDoor(veh)", Vehicle.CloseDoor, veh)
test_call("Vehicle.CloseDoor(veh, 0)", Vehicle.CloseDoor, veh, 0)

-- Turret / Heli
test_call("Vehicle.SetTurretPitch(veh, 0)", Vehicle.SetTurretPitch, veh, 0)
test_call("Vehicle.SetTurretYaw(veh, 0)", Vehicle.SetTurretYaw, veh, 0)
test_call("Vehicle.SpinHeli(veh)", Vehicle.SpinHeli, veh)

return table.concat(r, "\n")
