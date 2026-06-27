local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lc = Player.GetLocalCharacter()
local model = Object.GetModelName(lc)
log("Model handle: " .. tostring(model))

local function test(label, fn, ...)
    local ok, val = pcall(fn, ...)
    log(string.format("%s => ok=%s, val=%s (%s)", label, tostring(ok), tostring(val), type(val)))
end

test("GuidToString(model)", Sys.GuidToString, model)

-- Test with some hash values
local hash1 = 0xb7f587a3
test("GuidToString(0xb7f587a3)", Sys.GuidToString, hash1)
test("GuidToString('0xb7f587a3')", Sys.GuidToString, '0xb7f587a3')
test("GuidToString('[0xb7f587a3]')", Sys.GuidToString, '[0xb7f587a3]')

return table.concat(r, "\n")
