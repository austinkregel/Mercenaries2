local ok, err = pcall(Hud.ClassyText.ShowText, Hud.ClassyText, {
    sText = "Hello from Lua Bridge!",
    nDuration = 5
})
return tostring(ok) .. " : " .. tostring(err)
