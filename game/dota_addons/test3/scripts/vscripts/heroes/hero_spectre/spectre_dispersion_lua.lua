spectre_dispersion_lua = class({})
LinkLuaModifier("modifier_spectre_dispersion_lua", "heroes/hero_spectre/modifier_spectre_dispersion_lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Passive Modifier
function spectre_dispersion_lua:GetIntrinsicModifierName()
    return "modifier_spectre_dispersion_lua"
end