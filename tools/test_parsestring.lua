local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local hash = "[0xb7f587a3]"

local function test(label, fn, ...)
    local ok, val = pcall(fn, ...)
    log(string.format("%s => ok=%s, val=%s", label, tostring(ok), tostring(val)))
end

test("mrxguipda._ParseString(hash)", _MODULES.mrxguipda._ParseString, hash)
test("mrxguisupportshop._ParseString(hash)", _MODULES.mrxguisupportshop._ParseString, hash)

test("mrxguipda._ParseString('[0x5cb97d23]')", _MODULES.mrxguipda._ParseString, "[0x5cb97d23]")
test("mrxguipda._ParseString('Plain Text')", _MODULES.mrxguipda._ParseString, "Plain Text")

return table.concat(r, "\n")
