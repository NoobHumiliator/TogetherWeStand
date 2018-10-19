boss_sand_king_burrowstrike = class({})
LinkLuaModifier( "modifier_boss_sand_king_burrowstrike", "creature_ability/round_12_2/modifiers/modifier_boss_sand_king_burrowstrike", LUA_MODIFIER_MOTION_HORIZONTAL )
LinkLuaModifier( "modifier_boss_sand_king_burrowstrike_end", "creature_ability/round_12_2/modifiers/modifier_boss_sand_king_burrowstrike_end", LUA_MODIFIER_MOTION_HORIZONTAL )
--------------------------------------------------------------------------------

function boss_sand_king_burrowstrike:OnAbilityPhaseStart()
	if IsServer() then
	end

	return true
end

--------------------------------------------------------------------------------

function boss_sand_king_burrowstrike:OnAbilityPhaseInterrupted()
	if IsServer() then
	end
end

--------------------------------------------------------------------------------

function boss_sand_king_burrowstrike:GetCastPoint()
	return 1.0625 - ( 0.53125 * ( 1 - ( self:GetCaster():GetHealthPercent() / 100 ) ) )
end

--------------------------------------------------------------------------------

function boss_sand_king_burrowstrike:GetPlaybackRateOverride()
	return 0.3045 + ( 0.3045 * ( 1 - ( self:GetCaster():GetHealthPercent() / 100 ) ) )
end

--------------------------------------------------------------------------------

function boss_sand_king_burrowstrike:OnSpellStart()
	if IsServer() then
		local vToTarget = self:GetCursorPosition() - self:GetCaster():GetOrigin()
		local flDist = RandomFloat( 1000.0, 2000.0 )
		local vDir = vToTarget:Normalized()
		vDir.z = 0.0

		local vTarget = self:GetCaster():GetOrigin() + vDir * flDist

		local flHealthPct = self:GetCaster():GetHealthPercent() / 100
		local kv =
		{
			x = vTarget.x,
			y = vTarget.y,
			z = vTarget.z,
			duration = flDist / ( self:GetSpecialValueFor( "speed" ) + ( self:GetSpecialValueFor( "scaling_speed" ) * ( 1 - flHealthPct ) ) )
		}
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_boss_sand_king_burrowstrike", kv )
		EmitSoundOn( "SandKingBoss.BurrowStrike", self:GetCaster() )

		local nFXIndex = ParticleManager:CreateParticle( "particles/test_particle/sandking_burrowstrike_no_models.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetCaster():GetOrigin() + self:GetCaster():GetForwardVector() * 225  )
		ParticleManager:SetParticleControl( nFXIndex, 1, self:GetCaster():GetOrigin() + self:GetCaster():GetForwardVector() * 225  )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
	end
end

--------------------------------------------------------------------------------