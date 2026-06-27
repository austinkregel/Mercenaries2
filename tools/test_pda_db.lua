local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local function test(label, fn, ...)
    local ok, err = pcall(fn, ...)
    log(string.format("%s => ok=%s, err=%s", label, tostring(ok), tostring(err)))
end

test("AddHelpEntry()", Pda.Database.AddHelpEntry)
test("AddHelpEntry('test')", Pda.Database.AddHelpEntry, "test")
test("AddHelpEntry('test', 'test2')", Pda.Database.AddHelpEntry, "test", "test2")

test("AddLogEntry()", Pda.Database.AddLogEntry)
test("AddLogEntry('test')", Pda.Database.AddLogEntry, "test")

test("AddDossierEntry()", Pda.Database.AddDossierEntry)
test("AddDossierEntry('test')", Pda.Database.AddDossierEntry, "test")

return table.concat(r, "\n")
