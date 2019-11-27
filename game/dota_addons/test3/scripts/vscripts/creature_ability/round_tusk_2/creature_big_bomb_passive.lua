creature_big_bomb_passive = class({})
LinkLuaModifier( "modifier_creature_big_bomb_passive", "creature_ability/round_tusk_2/modifier_creature_big_bomb_passive", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function creature_big_bomb_passive:GetIntrinsicModifierName()
	return "modifier_creature_big_bomb_passive"
end