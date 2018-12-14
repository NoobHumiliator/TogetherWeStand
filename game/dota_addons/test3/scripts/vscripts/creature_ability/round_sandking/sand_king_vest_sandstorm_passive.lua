sand_king_vest_sandstorm_passive = class({})
LinkLuaModifier( "modifier_boss_sand_king_sandstorm", "creature_ability/round_sandking/modifiers/modifier_boss_sand_king_sandstorm", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_boss_sand_king_sandstorm_effect", "creature_ability/round_sandking/modifiers/modifier_boss_sand_king_sandstorm_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_sand_king_sandstorm_blind", "creature_ability/round_sandking/modifiers/modifier_boss_sand_king_sandstorm_blind", LUA_MODIFIER_MOTION_NONE )


-----------------------------------------------------------------------------------------

function sand_king_vest_sandstorm_passive:GetIntrinsicModifierName()
	return "modifier_boss_sand_king_sandstorm"
end

-----------------------------------------------------------------------------------------
