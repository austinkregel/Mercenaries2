local ok, err = pcall(Net.SendEvent_TextFanfare, "Fanfare Payload C!", "Subtext C!")
return tostring(ok) .. " : " .. tostring(err)
