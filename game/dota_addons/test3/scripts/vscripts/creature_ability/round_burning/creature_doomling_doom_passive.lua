creature_doomling_doom_passive = class({})
LinkLuaModifier( "modifier_creature_doomling_doom_passive", "creature_ability/round_burning/modifier_creature_doomling_doom_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_impending_doom", "creature_ability/round_burning/modifier_impending_doom", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function creature_doomling_doom_passive:GetIntrinsicModifierName()
	return "modifier_creature_doomling_doom_passive"
end
