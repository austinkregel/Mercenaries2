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
            if type(v) == "table" then
                local tbl_parts = {}
                for k, val in pairs(v) do
                    tbl_parts[#tbl_parts+1] = string.format("%s=%s", tostring(k), tostring(val))
                end
                parts[i] = "table={" .. table.concat(tbl_parts, ", ") .. "}"
            else
                parts[i] = string.format("%s=%s", type(v), tostring(v))
            end
        end
        log(string.format("OK[%d] %s => %s", n, label, table.concat(parts, ", ")))
    end
    got(pcall(fn, ...))
end

local lp = Player.GetLocalPlayer()
local lc = Player.GetLocalCharacter()
local veh, seat = Object.InVehicle(lc)

log("Local Player: " .. tostring(lp))
log("Local Character: " .. tostring(lc))
log("Vehicle: " .. tostring(veh))
log("Seat: " .. tostring(seat))

if veh then
    test_call("Vehicle.GetDriver(veh)", Vehicle.GetDriver, veh)
    test_call("Vehicle.GetRiders(veh)", Vehicle.GetRiders, veh)
    test_call("Vehicle.GetFromRider(lc)", Vehicle.GetFromRider, lc)
    test_call("Vehicle.GetFromSeat(veh, seat)", Vehicle.GetFromSeat, veh, seat)
    test_call("Vehicle.GetRiderFromSeat(veh, seat)", Vehicle.GetRiderFromSeat, veh, seat)
    test_call("Vehicle.GetSeatFromRider(veh, lc)", Vehicle.GetSeatFromRider, veh, lc)
    test_call("Vehicle.GetSeatFromRider(lc)", Vehicle.GetSeatFromRider, lc)
    test_call("Vehicle.GetSeatParams(veh, seat)", Vehicle.GetSeatParams, veh, seat)
    
    -- Check if we can open the specific seat's door using the seat handle
    test_call("Vehicle.OpenDoor(veh, seat)", Vehicle.OpenDoor, veh, seat)
    test_call("Vehicle.CloseDoor(veh, seat)", Vehicle.CloseDoor, veh, seat)
    
    -- Try to find seat by type
    test_call("Vehicle.GetSeatByType(veh, 'driver')", Vehicle.GetSeatByType, veh, "driver")
    test_call("Vehicle.GetSeatByType(veh, 0)", Vehicle.GetSeatByType, veh, 0)
    
    -- Let's check Object.GetHealth and GetMaxHealth again. Wait, did they return nil before?
    -- Yes, for the vehicle, Object.GetHealth(veh) returned nil.
    -- Wait, what does Object.GetPhysicsType(veh) return? It returned boolean=false.
end

return table.concat(r, "\n")
