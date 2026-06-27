local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

_G.MyTickCount = 0

_G.MyTestTick2 = function()
    _G.MyTickCount = _G.MyTickCount + 1
    
    -- Print to game debug log!
    -- Wait, the print function is hooked, let's write to print or call debug print
    local status = "[tick] execution number: " .. _G.MyTickCount
    pcall(Hud.MessageBox.AddMessage, Hud.MessageBox, {
        vPlayer = Player.GetLocalPlayer(),
        sMessage = status,
        nPriority = 1,
        nDuration = 2
    })
    
    -- Also save execution logs in a global table so we can check it
    _G.MyTickLogs = _G.MyTickLogs or {}
    table.insert(_G.MyTickLogs, status)
    
    if _G.MyTickCount < 5 then
        pcall(Event.Create, Event.TimerRelative, 1.0, _G.MyTestTick2)
    else
        table.insert(_G.MyTickLogs, "[tick] loop finished!")
    end
end

-- Start it!
local ok, err = pcall(Event.Create, Event.TimerRelative, 1.0, _G.MyTestTick2)
log("Started: " .. tostring(ok) .. ", err=" .. tostring(err))

return table.concat(r, "\n")
