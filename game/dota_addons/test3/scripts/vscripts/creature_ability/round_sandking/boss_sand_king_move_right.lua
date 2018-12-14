boss_sand_king_move_right = class({})

-----------------------------------------------------------------

function boss_sand_king_move_right:OnAbilityPhaseStart()
	if IsServer() then
		local flMin = self:GetSpecialValueFor( "minimum_duration" )
		local flMax = self:GetSpecialValueFor( "maximum_duration" )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_boss_sand_king_directional_move", { duration = RandomFloat( flMin, flMax ) } )
	end
	return true
end


-----------------------------------------------------------------------------

function boss_sand_king_move_right:GetPlaybackRateOverride()
	return 1
end

-----------------------------------------------------------------

function boss_sand_king_move_right:OnSpellStart()
	if IsServer() then
	end
end