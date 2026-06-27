local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local tick_count = 0

-- Define our global tick function so the engine doesn't garbage collect the reference!
_G.MyTestTick = function()
    tick_count = tick_count + 1
    Hud.MessageBox:AddMessage({
        vPlayer = Player.GetLocalPlayer(),
        sMessage = "MOD LOOP TICK: " .. tick_count,
        nPriority = 1,
        nDuration = 2
    })
    
    if tick_count < 5 then
        -- Schedule next tick in 1.5 seconds
        local ok, err = pcall(Event.Create, Event.TimerRelative, 1.5, _G.MyTestTick)
        if not ok then
            -- Let's try passing arguments in different orders
            pcall(Event.Create, Event.TimerRelative, _G.MyTestTick, 1.5)
        end
    else
        Hud.MessageBox:AddMessage({
            vPlayer = Player.GetLocalPlayer(),
            sMessage = "MOD LOOP COMPLETE!",
            nPriority = 1,
            nDuration = 3
        })
        _G.MyTestTick = nil -- Cleanup
    end
end

-- Start the loop
local ok, err = pcall(Event.Create, Event.TimerRelative, 1.5, _G.MyTestTick)
if not ok then
    log("Event.Create failed with (TimerRelative, duration, callback): " .. tostring(err))
    
    -- Try the other order (TimerRelative, callback, duration)
    local ok2, err2 = pcall(Event.Create, Event.TimerRelative, _G.MyTestTick, 1.5)
    if not ok2 then
        log("Event.Create failed with (TimerRelative, callback, duration): " .. tostring(err2))
    else
        log("Succeeded with (TimerRelative, callback, duration)")
    end
else
    log("Succeeded with (TimerRelative, duration, callback)")
end

return table.concat(r, "\n")
