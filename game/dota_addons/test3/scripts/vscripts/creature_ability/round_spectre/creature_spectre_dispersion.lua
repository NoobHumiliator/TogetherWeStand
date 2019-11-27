creature_spectre_dispersion = class({})
LinkLuaModifier("modifier_creature_spectre_dispersion", "creature_ability/round_spectre/modifier_creature_spectre_dispersion", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Passive Modifier
function creature_spectre_dispersion:GetIntrinsicModifierName()
    return "modifier_creature_spectre_dispersion"
end