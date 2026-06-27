local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()

local ok1, err1 = pcall(Hud.ObjectiveTray.SetSlotToText, Hud.ObjectiveTray, {
    vPlayer = lp,
    nSlot = 0,
    sText = "Antigravity Active",
    bDontNetSync = true
})
log(string.format("SetSlotToText(0) => ok=%s, err=%s", tostring(ok1), tostring(err1)))

local ok2, err2 = pcall(Hud.ObjectiveTray.SetSlotToText, Hud.ObjectiveTray, {
    vPlayer = lp,
    nSlot = 1,
    sText = "Explore custom UI elements",
    bDontNetSync = true
})
log(string.format("SetSlotToText(1) => ok=%s, err=%s", tostring(ok2), tostring(err2)))

return table.concat(r, "\n")
