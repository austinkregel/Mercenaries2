-- ============================================================================
-- Open the dev cheat menu in Mercenaries 2.
--
-- Authored entirely by u/Kunster_ on r/MercenariesGames. Reproduced here
-- unmodified for the Merc2Reborn repo as a reference recipe.
--
-- Source / context:
--   https://www.reddit.com/r/MercenariesGames/comments/1ufm2d1/mercenaries_2_pc_cheat_menu/
--
-- Why this version: it handles game-state variations where the
-- `Cheat.DisplayOptions` global may not be installed yet. The script
-- walks four fallback tiers:
--
--   1. Cheat.DisplayOptions                        (public wrapper, if bootstrapped)
--   2. _MODULES.mrxcheatbootstrap.DisplayOptions   (module's public method)
--   3. _MODULES.mrxcheatbootstrap._DisplayRootDialog (private function)
--   4. import("mrxcheatbootstrap") then retry tiers 1-3
--
-- The simpler one-liner `Cheat.DisplayOptions()` works when the
-- cheat-bootstrap module is already resident, but the version below is
-- the right thing to ship if you don't control the target's load state.
-- ============================================================================

local f = nil
local src = "none"

-- First try the globally exported cheat interface.
if type(Cheat) == "table"
and type(Cheat.DisplayOptions) == "function" then
    f = Cheat.DisplayOptions
    src = "Cheat.DisplayOptions"
end

-- Then check whether the cheat-bootstrap module is already resident.
local m = nil

if type(_MODULES) == "table" then
    m = _MODULES.mrxcheatbootstrap
end

if type(f) ~= "function" and type(m) == "table" then
    if type(m.DisplayOptions) == "function" then
        f = m.DisplayOptions
        src = "_MODULES.mrxcheatbootstrap.DisplayOptions"

    elseif type(m._DisplayRootDialog) == "function" then
        f = m._DisplayRootDialog
        src = "_MODULES.mrxcheatbootstrap._DisplayRootDialog"
    end
end

-- If necessary, import the retail cheat-bootstrap script.
if type(f) ~= "function" and type(import) == "function" then
    pcall(import, "mrxcheatbootstrap")

    -- Importing may create the global Cheat table.
    if type(Cheat) == "table"
    and type(Cheat.DisplayOptions) == "function" then
        f = Cheat.DisplayOptions
        src = "import -> Cheat.DisplayOptions"
    end

    -- Or it may only register the resident module.
    if type(_MODULES) == "table" then
        m = _MODULES.mrxcheatbootstrap or m
    end

    if type(f) ~= "function" and type(m) == "table" then
        if type(m.DisplayOptions) == "function" then
            f = m.DisplayOptions
            src = "import -> _MODULES.mrxcheatbootstrap.DisplayOptions"

        elseif type(m._DisplayRootDialog) == "function" then
            f = m._DisplayRootDialog
            src = "import -> _MODULES.mrxcheatbootstrap._DisplayRootDialog"
        end
    end
end

if type(f) ~= "function" then
    error(
        "Native cheat menu is unavailable. " ..
        "Cheat.DisplayOptions=" ..
        type(type(Cheat) == "table" and Cheat.DisplayOptions or nil) ..
        ", mrxcheatbootstrap=" ..
        type(m)
    )
end

local ok, result = pcall(f)

if not ok then
    error(
        "Opening the cheat menu through " ..
        src ..
        " failed: " ..
        tostring(result)
    )
end

return result
