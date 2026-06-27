local ok, err = pcall(Hud.Announcement.Show, Hud.Announcement, {})
return tostring(ok) .. " : " .. tostring(err)
