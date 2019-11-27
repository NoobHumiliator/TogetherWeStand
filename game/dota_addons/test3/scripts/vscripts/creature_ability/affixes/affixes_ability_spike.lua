affixes_ability_spike = class({})
LinkLuaModifier("modifier_affixes_spike_permanent", "creature_ability/affixes/modifier_affixes_spike_permanent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_affixes_spike_warning", "creature_ability/affixes/modifier_affixes_spike_warning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_affixes_spike", "creature_ability/affixes/modifier_affixes_spike", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Passive Modifier
function affixes_ability_spike:GetIntrinsicModifierName()
    return "modifier_affixes_spike_permanent"
end