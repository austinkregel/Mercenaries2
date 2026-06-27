local ok, err = pcall(Hud.ClassyText.ShowText, {})
return tostring(ok) .. " : " .. tostring(err)
