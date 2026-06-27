local ok, err = pcall(Hud.Announcement.Show, Hud.Announcement, {
    sText = "Announcement from Lua!",
    nDuration = 5
})
return tostring(ok) .. " : " .. tostring(err)
