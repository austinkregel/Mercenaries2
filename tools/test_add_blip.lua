local r = {}
local function log(msg) r[#r+1] = tostring(msg) end

local lp = Player.GetLocalPlayer()
local lc = Player.GetLocalCharacter()

local ok, err = pcall(Pda.Map.AddBlip, Pda.Map, {
    vPlayer = lp,
    sName = "AntigravityBlip",
    sLabel = "Antigravity Point",
    sDesc = "A custom Lua map blip.",
    uGuid = lc,
    sTexture = "HUD_faction_OC",
    bSticky = true
})

log(string.format("AddBlip => ok=%s, err=%s", tostring(ok), tostring(err)))

return table.concat(r, "\n")
