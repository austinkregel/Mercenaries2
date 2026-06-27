local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

_G.MyTickCount = 0
_G.MyTickLogs = {}

_G.MyTestTick3 = function(data)
    _G.MyTickCount = _G.MyTickCount + 1
    
    local status = "[tick] number: " .. _G.MyTickCount .. ", payload: " .. tostring(data and data[1] or "none")
    table.insert(_G.MyTickLogs, status)
    
    pcall(Hud.MessageBox.AddMessage, Hud.MessageBox, {
        vPlayer = Player.GetLocalPlayer(),
        sMessage = status,
        nPriority = 1,
        nDuration = 2
    })
    
    if _G.MyTickCount < 4 then
        -- Schedule next tick in 1.2 seconds, passing {"nested_payload"} as data
        local ok, err = pcall(Event.Create, Event.TimerRelative, { 1.2 }, _G.MyTestTick3, { "active" })
    else
        table.insert(_G.MyTickLogs, "[tick] loop finished!")
    end
end

-- Start it with { 1.2 } delay table and { "start" } as data
local ok, err = pcall(Event.Create, Event.TimerRelative, { 1.2 }, _G.MyTestTick3, { "start" })
log("Started: " .. tostring(ok) .. ", err=" .. tostring(err))

return table.concat(r, "\n")
