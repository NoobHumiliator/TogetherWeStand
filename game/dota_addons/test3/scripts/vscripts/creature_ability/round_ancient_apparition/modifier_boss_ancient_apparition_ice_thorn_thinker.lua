modifier_boss_ancient_apparition_ice_thorn_thinker = class({})

------------------------------------------------------------------

function modifier_boss_ancient_apparition_ice_thorn_thinker:IsHidden()
	return true
end

------------------------------------------------------------------

function modifier_boss_ancient_apparition_ice_thorn_thinker:IsPurgable() 
	return false
end

------------------------------------------------------------------

function modifier_boss_ancient_apparition_ice_thorn_thinker:OnCreated( kv )
	if IsServer() and self:GetAbility() == nil then
		self:Destroy()
		UTIL_Remove( self:GetParent() )
		return
	end

	if IsServer() then
		self.delay = self:GetAbility():GetSpecialValueFor( "delay" )
		self.damage = self:GetAbility():GetSpecialValueFor( "damage" )
		self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
		self.freeze_duration = self:GetAbility():GetSpecialValueFor( "freeze_duration" )

		local nFXIndex = ParticleManager:CreateParticle( "particles/test_particle/dungeon_generic_blast_ovr_pre.vpcf", PATTACH_CUSTOMORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.delay, 1.0 ) )
		ParticleManager:SetParticleControl( nFXIndex, 15, Vector( 100, 100, 255 ) )
		ParticleManager:SetParticleControl( nFXIndex, 16, Vector( 1, 0, 0 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		self:StartIntervalThink( self.delay )
	end
end

------------------------------------------------------------------

function modifier_boss_ancient_apparition_ice_thorn_thinker:OnIntervalThink()
	if IsServer() then
		EmitSoundOnLocationWithCaster( self:GetParent():GetOrigin(), "Hero_Tusk.IceShards", self:GetCaster() )

		local nFXIndex = ParticleManager:CreateParticle( "particles/act_2/frostbitten_icicle.vpcf", PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() + Vector( 0, 0, 40 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )

		local enemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), self.radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,enemy in pairs( enemies ) do
			if enemy ~= nil and enemy:IsMagicImmune() == false and enemy:IsInvulnerable() == false then
				local damageInfo =
				{
					victim = enemy,
					attacker = self:GetCaster() or self:GetParent(), -- caster might be dead, but parent thinker probably can't be
					damage = self.damage,
					damage_type = DAMAGE_TYPE_MAGICAL,
					ability = self,
				}
				ApplyDamage( damageInfo )
				enemy:AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_boss_ancient_apparition_ice_thorn", { duration = self.freeze_duration } )
			end
		end

        local hThinker = CreateModifierThinker( self:GetParent(), self:GetAbility(), "modifier_earthshaker_fissure", {}, self:GetParent():GetOrigin(), self:GetCaster():GetTeamNumber(), true )
        hThinker:SetHullRadius( 65 )
        if RandomInt(0, 100) < 50 then
           hThinker:SetModel("maps/cavern_assets/models/crystals/crystal_cavern_01.vmdl")
        else
           hThinker:SetModel("maps/cavern_assets/models/crystals/crystal_cavern_02.vmdl")
        end
        if self:GetCaster().vThornThinkers==nil then
           self:GetCaster().vThornThinkers={}
        end

        --将尖刺存入施法者
        table.insert(self:GetCaster().vThornThinkers, hThinker)
        
	    self:Destroy()
		UTIL_Remove( self:GetParent() )
	end
end

-----------------------------------------------------------------------------