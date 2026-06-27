local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()

local function test(label, fn, ...)
    local ok, err = pcall(fn, Pda.Database, ...)
    log(string.format("%s => ok=%s, err=%s", label, tostring(ok), tostring(err)))
end

test("AddHelpEntry", Pda.Database.AddHelpEntry, {
    vPlayer = lp,
    sTitle = "Antigravity Guide",
    sText = "Learn how to use the Lua bridge to command the game engine.",
    sIcon = "icon_oc_mc"
})

test("AddLogEntry", Pda.Database.AddLogEntry, {
    vPlayer = lp,
    sType = "System",
    sName = "Lua REPL",
    sMessage = "Probing completed successfully.",
    sColor = "green"
})

test("AddDossierEntry", Pda.Database.AddDossierEntry, {
    vPlayer = lp,
    sTitle = "Antigravity",
    sText = "AI Coding Assistant pair programming with user.",
    sIcon = "icon_an_mc"
})

return table.concat(r, "\n")
