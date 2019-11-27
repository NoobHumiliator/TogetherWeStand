creature_nyx_spike = class({})
LinkLuaModifier("modifier_nyx_spike_permanent", "creature_ability/round_nyx/modifier_nyx_spike_permanent", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nyx_spike_warning", "creature_ability/round_nyx/modifier_nyx_spike_warning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_nyx_spike", "creature_ability/round_nyx/modifier_nyx_spike", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Passive Modifier
function creature_nyx_spike:GetIntrinsicModifierName()
    return "modifier_nyx_spike_permanent"
end