local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()

-- Test 1: Text Fanfare
local ok1, err1 = pcall(Hud.TextFanfare.Commence, Hud.TextFanfare, {
    sLine1 = "LUA BRIDGE",
    sLine2 = "CONNECTED",
    nEntranceTime = 1.0,
    nDisplayTime = 5.0,
    nFadeTime = 1.0
})
log(string.format("TextFanfare:Commence => ok=%s, err=%s", tostring(ok1), tostring(err1)))

-- Test 2: Message Box
local ok2, err2 = pcall(Hud.MessageBox.AddMessage, Hud.MessageBox, {
    vPlayer = lp,
    sMessage = "Hello from Lua Bridge!",
    nPriority = 1,
    nDuration = 5
})
log(string.format("MessageBox:AddMessage => ok=%s, err=%s", tostring(ok2), tostring(err2)))

return table.concat(r, "\n")
