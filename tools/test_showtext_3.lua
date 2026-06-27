local ok, err = pcall(Hud.ClassyText.ShowText, Hud.ClassyText, {})
return tostring(ok) .. " : " .. tostring(err)
