boss_sand_king_passive = class({})
LinkLuaModifier( "modifier_boss_sand_king_passive", "creature_ability/round_12_2/modifiers/modifier_boss_sand_king_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_sand_king_boss_caustic_finale", "creature_ability/round_12_2/modifiers/modifier_sand_king_boss_caustic_finale", LUA_MODIFIER_MOTION_NONE )



-----------------------------------------------------------------------------------------

function boss_sand_king_passive:GetIntrinsicModifierName()
	return "modifier_boss_sand_king_passive"
end

-----------------------------------------------------------------------------------------
