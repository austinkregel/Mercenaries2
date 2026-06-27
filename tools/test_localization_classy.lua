local lp = Player.GetLocalPlayer()
local lc = Player.GetLocalCharacter()
local name_hash = Object.GetLocalizedName(lc)

local ok, err = pcall(Hud.ClassyText.ShowText, Hud.ClassyText, {
    sText = "Local Character: " .. tostring(name_hash),
    nDuration = 5
})

return string.format("ShowText ok=%s, err=%s, hash=%s", tostring(ok), tostring(err), tostring(name_hash))
