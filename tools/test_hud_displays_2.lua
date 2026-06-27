local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()

-- Test 1: Announcement
local ok1, err1 = pcall(Hud.Announcement.Show, Hud.Announcement, {
    vPlayer = lp,
    sTexture = "HUD_faction_OC",
    nDuration = 5
})
log(string.format("Announcement:Show => ok=%s, err=%s", tostring(ok1), tostring(err1)))

-- Test 2: Tutorial
local ok2, err2 = pcall(Hud.Tutorial.ShowTutorialOnscreen, Hud.Tutorial, {
    vPlayer = lp,
    sMessage = "This is a custom tutorial window.",
    nDuration = 5
})
log(string.format("Tutorial:ShowTutorialOnscreen => ok=%s, err=%s", tostring(ok2), tostring(err2)))

return table.concat(r, "\n")
