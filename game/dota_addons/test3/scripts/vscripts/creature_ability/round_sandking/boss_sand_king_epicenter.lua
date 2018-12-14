boss_sand_king_epicenter = class({})
LinkLuaModifier( "modifier_boss_sand_king_epicenter", "creature_ability/round_sandking/modifiers/modifier_boss_sand_king_epicenter", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function boss_sand_king_epicenter:OnAbilityPhaseStart()
	if IsServer() then
		self.nPreviewFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_sandking/sandking_epicenter_tell.vpcf", PATTACH_CUSTOMORIGIN, self:GetCaster() )
		ParticleManager:SetParticleControlEnt( self.nPreviewFX, 0, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_tail", self:GetCaster():GetOrigin(), true )
		EmitSoundOn( "SandKingBoss.Epicenter.spell", self:GetCaster() )
		self.nChannelFX = ParticleManager:CreateParticle( "particles/test_particle/dungeon_sand_king_channel.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	end
	return true
end

--------------------------------------------------------------------------------

function boss_sand_king_epicenter:OnAbilityPhaseInterrupted()
	if IsServer() then
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
	end
end

--------------------------------------------------------------------------------

function boss_sand_king_epicenter:GetChannelAnimation()
	return ACT_DOTA_CAST_ABILITY_4
end

--------------------------------------------------------------------------------

function boss_sand_king_epicenter:GetPlaybackRateOverride()
	return 1
end

--------------------------------------------------------------------------------

function boss_sand_king_epicenter:OnSpellStart()
	if IsServer() then
		self.Projectiles = {}
		ParticleManager:DestroyParticle( self.nPreviewFX, false )
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_boss_sand_king_epicenter", {} )
	end
end

--------------------------------------------------------------------------------

function boss_sand_king_epicenter:OnChannelFinish( bInterrupted )
	if IsServer() then
		self:GetCaster():RemoveModifierByName( "modifier_boss_sand_king_epicenter" )
		ParticleManager:DestroyParticle( self.nChannelFX, false )
	end
end

--------------------------------------------------------------------------------

function boss_sand_king_epicenter:OnProjectileThinkHandle( nProjectileHandle )
	if IsServer() then
		local projectile = nil
		for _,proj in pairs( self.Projectiles ) do
			if proj ~= nil and proj.handle == nProjectileHandle then
				projectile = proj
			end
		end
		if projectile ~= nil then
			local flRadius = ProjectileManager:GetLinearProjectileRadius( nProjectileHandle )
			ParticleManager:SetParticleControl( projectile.nFXIndex, 2, Vector( flRadius, flRadius, 0 ) )
		end	
	end
end

--------------------------------------------------------------------------------

function boss_sand_king_epicenter:OnProjectileHitHandle( hTarget, vLocation, nProjectileHandle )
	if IsServer() then
		if hTarget ~= nil then
			local blocker_radius = self:GetSpecialValueFor( "blocker_radius" )


			local vFromCaster = vLocation - self:GetCaster():GetOrigin()
			vFromCaster = vFromCaster:Normalized()
			local vToCasterPerp  = Vector( -vFromCaster.y, vFromCaster.x, 0 )

			local vLoc1 = vLocation + vFromCaster * 200
			local vLoc2 = vLocation + vFromCaster * 200 + vToCasterPerp * 65
			local vLoc3 = vLocation + vFromCaster * 200 + vToCasterPerp * -65

            if self:GetCaster().vFissures==nil then
               self:GetCaster().vFissures={}
            end

			local hThinker = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc1, self:GetCaster():GetTeamNumber(), true )
			local hThinker2 = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc2, self:GetCaster():GetTeamNumber(), true )
			local hThinker3 = CreateModifierThinker( self:GetCaster(), self, "modifier_earthshaker_fissure", {}, vLoc3, self:GetCaster():GetTeamNumber(), true )
			if hThinker ~= nil then
				hThinker:SetHullRadius( 65 )
				local nFXIndex = ParticleManager:CreateParticle( "particles/test_particle/dungeon_sand_king_blocker.vpcf", PATTACH_WORLDORIGIN, nil )
				ParticleManager:SetParticleControl( nFXIndex, 0, vLoc1 )
				ParticleManager:SetParticleControl( nFXIndex, 1, vLoc1 )
				ParticleManager:SetParticleControl( nFXIndex, 2, Vector( 99999, 0, 0 ) )
				hThinker.nFXIndex=nFXIndex
                table.insert(self:GetCaster().vFissures,hThinker)
			end
			if hThinker2 ~= nil then
				hThinker2:SetHullRadius( 65 )
				local nFXIndex = ParticleManager:CreateParticle( "particles/test_particle/dungeon_sand_king_blocker.vpcf", PATTACH_WORLDORIGIN, nil )
				ParticleManager:SetParticleControl( nFXIndex, 0, vLoc2 )
				ParticleManager:SetParticleControl( nFXIndex, 1, vLoc2 )
				ParticleManager:SetParticleControl( nFXIndex, 2, Vector( 99999, 0, 0 ) )
				hThinker2.nFXIndex=nFXIndex
				table.insert(self:GetCaster().vFissures,hThinker2)
			end
			if hThinker3 ~= nil then
				hThinker3:SetHullRadius( 65 )
				local nFXIndex = ParticleManager:CreateParticle( "particles/test_particle/dungeon_sand_king_blocker.vpcf", PATTACH_WORLDORIGIN, nil )
				ParticleManager:SetParticleControl( nFXIndex, 0, vLoc3 )
				ParticleManager:SetParticleControl( nFXIndex, 1, vLoc3 )
				ParticleManager:SetParticleControl( nFXIndex, 2, Vector( 99999, 0, 0 ) )
				hThinker3.nFXIndex=nFXIndex
				table.insert(self:GetCaster().vFissures,hThinker3)
			end
			EmitSoundOn( "SandKingBoss.Epicenter.Impact", hTarget )
			

			local enemies = FindUnitsInRadius( self:GetCaster():GetTeamNumber(), hTarget:GetOrigin(), self:GetCaster(), blocker_radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
			for _,enemy in pairs( enemies ) do
				if enemy ~= nil and enemy:IsInvulnerable() == false and enemy:IsMagicImmune() == false then
					local kv =
					{
						center_x = hTarget:GetOrigin().x,
						center_y = hTarget:GetOrigin().y,
						center_z = hTarget:GetOrigin().z,
						should_stun = true, 
						duration = 0.25,
						knockback_duration = 0.25,
						knockback_distance = 250,
						knockback_height = 125,
					}
					enemy:AddNewModifier( self:GetCaster(), self, "modifier_knockback", kv )
					local damageInfo =
					{
						victim = enemy,
						attacker = self:GetCaster(),
						damage = self:GetSpecialValueFor( "damage" ),
						damage_type = DAMAGE_TYPE_PURE,
						ability = self,
					}
					ApplyDamage( damageInfo )
				end
			end
		end

		local projectile = nil
		for _,proj in pairs( self.Projectiles ) do
			if proj ~= nil and proj.handle == nProjectileHandle then
				projectile = proj
			end
		end
		if projectile ~= nil then
			ParticleManager:DestroyParticle( projectile.nFXIndex, false )
		end	
	end

	return true
end

--------------------------------------------------------------------------------