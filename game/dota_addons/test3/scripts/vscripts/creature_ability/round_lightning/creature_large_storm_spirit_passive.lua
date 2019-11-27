creature_large_storm_spirit_passive = class({})
LinkLuaModifier( "modifier_creature_large_storm_spirit_passive", "creature_ability/round_lightning/modifier_creature_large_storm_spirit_passive", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function creature_large_storm_spirit_passive:GetIntrinsicModifierName()
	return "modifier_creature_large_storm_spirit_passive"
end
