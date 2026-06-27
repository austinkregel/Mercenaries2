local lc = Player.GetLocalCharacter()
local hash = Object.GetLocalizedName(lc)

Hud.ClassyText:ShowText({
    sText = hash,
    nDuration = 10
})

return "Displayed name hash: " .. tostring(hash)
