local ok, err = pcall(Hud.ClassyText.ShowText, "Hello World")
return tostring(ok) .. " : " .. tostring(err)
