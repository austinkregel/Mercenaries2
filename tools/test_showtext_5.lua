local ok, err = pcall(Hud.ClassyText.ShowText, Hud.ClassyText, {
    sText = "ClassyText is working!",
    nDuration = 5
})
return tostring(ok) .. " : " .. tostring(err)
