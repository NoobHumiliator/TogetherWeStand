
boss_ancient_apparition_beam = class({})
LinkLuaModifier( "modifier_boss_ancient_apparition_beam", "creature_ability/round_ancient_apparition/modifier_boss_ancient_apparition_beam", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_ancient_apparition_frozen", "creature_ability/round_ancient_apparition/modifier_boss_ancient_apparition_frozen", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function boss_ancient_apparition_beam:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function boss_ancient_apparition_beam:OnAbilityPhaseStart()
	if IsServer() then
		self.nChannelFX = ParticleManager:CreateParticle( "particles/act_2/siltbreaker_beam_channel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	end
	return true
end

--------------------------------------------------------------------------------

function boss_ancient_apparition_beam:OnSpellStart()
	if IsServer() then
		Notifications:BossAbilityDBM("boss_ancient_apparition_beam")
		self.beam_range = self:GetSpecialValueFor( "beam_range" )
		self.initial_delay = self:GetSpecialValueFor( "initial_delay" )
		self.channel_time = self:GetChannelTime()

		local vDirection = self:GetCursorPosition() - self:GetCaster():GetOrigin()
		vDirection.z = 0.0
		vDirection = vDirection:Normalized()

		local vCasterPos = self:GetCaster():GetAbsOrigin()
		local vBeamEnd = vCasterPos + ( vDirection * self.beam_range )

		local kv =
		{
			duration = self.channel_time,
			vBeamEndX = vBeamEnd.x,
			vBeamEndY = vBeamEnd.y,
			vBeamEndZ = vCasterPos.z, -- don't want to pick weird Z if endpoint is on some different height
		}
		self.flAddTime = GameRules:GetGameTime() + self.initial_delay
		EmitSoundOn( "Hero_Phoenix.SunRay.Cast", self:GetCaster() )
	end
end

-------------------------------------------------------------------------------

function boss_ancient_apparition_beam:OnChannelThink( flInterval )
	if IsServer() then
		if self.flAddTime < GameRules:GetGameTime() and self:GetCaster():FindModifierByName( "modifier_boss_ancient_apparition_beam" ) == nil then
			EmitSoundOn( "Hero_Phoenix.SunRay.Loop", self:GetCaster() )
			self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_boss_ancient_apparition_beam", kv )
		end
	end
end

-------------------------------------------------------------------------------

function boss_ancient_apparition_beam:OnChannelFinish( bInterrupted )
	if IsServer() then
		ParticleManager:DestroyParticle( self.nChannelFX, false )
		StopSoundOn( "Hero_Phoenix.SunRay.Cast", self:GetCaster() )
		StopSoundOn( "Hero_Phoenix.SunRay.Loop", self:GetCaster() )
		EmitSoundOn( "Hero_Phoenix.SunRay.Stop", self:GetCaster() )
		self:GetCaster():RemoveModifierByName( "modifier_boss_ancient_apparition_beam" )
	end
end