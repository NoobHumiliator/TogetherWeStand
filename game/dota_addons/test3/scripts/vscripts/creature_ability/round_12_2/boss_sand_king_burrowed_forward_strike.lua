boss_sand_king_burrowed_forward_strike = class({})

--------------------------------------------------------------------------------

function boss_sand_king_burrowed_forward_strike:OnAbilityPhaseStart()
	if IsServer() then
		self.animation_time = self:GetSpecialValueFor( "animation_time" )
		self.initial_delay = self:GetSpecialValueFor( "initial_delay" )

		local kv = {}
		kv["duration"] = self.animation_time
		kv["initial_delay"] = self.initial_delay
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_sand_king_tail_swipe", kv )
	end
	return true
end

--------------------------------------------------------------------------------

function boss_sand_king_burrowed_forward_strike:OnAbilityPhaseInterrupted()
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_sand_king_tail_swipe" )
	end
end

--------------------------------------------------------------------------------

function boss_sand_king_burrowed_forward_strike:GetPlaybackRateOverride()
	return 0.70
end

--------------------------------------------------------------------------------

function boss_sand_king_burrowed_forward_strike:GetCastRange( vLocation, hTarget )
	if IsServer() then
		if self:GetCaster():FindModifierByName( "modifier_sand_king_tail_swipe" ) ~= nil then
			return 99999
		end
	end

	return self.BaseClass.GetCastRange( self, vLocation, hTarget )
end 