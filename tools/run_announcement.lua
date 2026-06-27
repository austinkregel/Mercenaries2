local ok, err = pcall(Hud.Announcement.Show, Hud.Announcement, {
    sText = "Announcement Payload A!",
    sMessage = "Announcement Payload A!",
    nDuration = 5
})
return tostring(ok) .. " : " .. tostring(err)
