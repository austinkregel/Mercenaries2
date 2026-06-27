local ok1, err1 = pcall(Net.SendEvent_ShowMessage, "Net Message from Lua!")
local ok2, err2 = pcall(Net.SendEvent_ShowMessage, "Net Message from Lua!", 5)
local ok3, err3 = pcall(Net.SendEvent_ShowMessage, Player.GetLocalPlayer(), "Net Message from Lua!", 5)
return string.format("1: %s:%s | 2: %s:%s | 3: %s:%s",
    tostring(ok1), tostring(err1),
    tostring(ok2), tostring(err2),
    tostring(ok3), tostring(err3))
