local r = {}

local function log(msg)
    r[#r+1] = tostring(msg)
end

local function test_call(label, fn, ...)
    local ok, err = pcall(fn, ...)
    if ok then
        log(string.format("[OK] %s -> (success, return: %s)", label, tostring(err)))
    else
        log(string.format("[ERR] %s -> %s", label, tostring(err)))
    end
end

local lp = Player.GetLocalPlayer()
local lc = Player.GetLocalCharacter()

log("Local Player: " .. tostring(lp))
log("Local Character: " .. tostring(lc))

log("\n--- Hud.ClassyText.ShowText ---")
test_call("ShowText()", Hud.ClassyText.ShowText)
test_call("ShowText('Hello World')", Hud.ClassyText.ShowText, "Hello World")
test_call("ShowText(lp, 'Hello World')", Hud.ClassyText.ShowText, lp, "Hello World")
test_call("ShowText('Hello World', 5)", Hud.ClassyText.ShowText, "Hello World", 5)

log("\n--- Hud.Announcement.Show ---")
test_call("Announcement.Show()", Hud.Announcement.Show)
test_call("Announcement.Show('Hello')", Hud.Announcement.Show, "Hello")
test_call("Announcement.Show(lp, 'Hello')", Hud.Announcement.Show, lp, "Hello")

log("\n--- Net.SendEvent_ShowMessage ---")
test_call("SendEvent_ShowMessage()", Net.SendEvent_ShowMessage)
test_call("SendEvent_ShowMessage('Hello')", Net.SendEvent_ShowMessage, "Hello")
test_call("SendEvent_ShowMessage(lp, 'Hello')", Net.SendEvent_ShowMessage, lp, "Hello")
test_call("SendEvent_ShowMessage('Hello', 5)", Net.SendEvent_ShowMessage, "Hello", 5)

log("\n--- Net.SendEvent_TextFanfare ---")
test_call("SendEvent_TextFanfare()", Net.SendEvent_TextFanfare)
test_call("SendEvent_TextFanfare('Hello')", Net.SendEvent_TextFanfare, "Hello")
test_call("SendEvent_TextFanfare('Hello', 'Sub')", Net.SendEvent_TextFanfare, "Hello", "Sub")
test_call("SendEvent_TextFanfare(lp, 'Hello', 'Sub')", Net.SendEvent_TextFanfare, lp, "Hello", "Sub")

return table.concat(r, "\n")
