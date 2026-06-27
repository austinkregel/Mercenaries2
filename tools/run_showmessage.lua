local ok, err = pcall(Net.SendEvent_ShowMessage, "ShowMessage Payload B!")
return tostring(ok) .. " : " .. tostring(err)
