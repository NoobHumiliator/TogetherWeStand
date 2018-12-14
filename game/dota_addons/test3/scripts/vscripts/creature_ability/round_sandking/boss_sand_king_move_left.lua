boss_sand_king_move_left = class({})
LinkLuaModifier( "modifier_boss_sand_king_directional_move", "creature_ability/round_sandking/modifiers/modifier_boss_sand_king_directional_move", LUA_MODIFIER_MOTION_HORIZONTAL )

-----------------------------------------------------------------

function boss_sand_king_move_left:OnAbilityPhaseStart()
	if IsServer() then
		local flMin = self:GetSpecialValueFor( "minimum_duration" )
		local flMax = self:GetSpecialValueFor( "maximum_duration" )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_boss_sand_king_directional_move", { duration = RandomFloat( flMin, flMax ) } )
	end
	return true
end

-----------------------------------------------------------------------------

function boss_sand_king_move_left:GetPlaybackRateOverride()
	return 1
end

-----------------------------------------------------------------

function boss_sand_king_move_left:OnSpellStart()
	if IsServer() then
	end
end