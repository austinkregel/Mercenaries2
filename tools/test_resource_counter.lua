local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()

local ok1, err1 = pcall(Hud.ResourceCounter.SetCash, Hud.ResourceCounter, {
    vPlayer = lp,
    nValue = 1234567,
    sReason = "LUA INJECTION"
})
log(string.format("SetCash => ok=%s, err=%s", tostring(ok1), tostring(err1)))

local ok2, err2 = pcall(Hud.ResourceCounter.Show, Hud.ResourceCounter, {
    vPlayer = lp,
    nDuration = 10
})
log(string.format("Show => ok=%s, err=%s", tostring(ok2), tostring(err2)))

return table.concat(r, "\n")
