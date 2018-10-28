sand_king_vest_sandstorm_passive = class({})
LinkLuaModifier( "modifier_sand_king_boss_sandstorm", "creature_ability/round_12_2/modifiers/modifier_boss_sand_king_sandstorm", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_sand_king_boss_sandstorm_effect", "creature_ability/round_12_2/modifiers/modifier_boss_sand_king_sandstorm_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sand_king_boss_sandstorm_blind", "creature_ability/round_12_2/modifiers/modifier_boss_sand_king_sandstorm_blind", LUA_MODIFIER_MOTION_NONE )


-----------------------------------------------------------------------------------------

function sand_king_vest_sandstorm_passive:GetIntrinsicModifierName()
	return "modifier_sand_king_boss_sandstorm"
end

-----------------------------------------------------------------------------------------
