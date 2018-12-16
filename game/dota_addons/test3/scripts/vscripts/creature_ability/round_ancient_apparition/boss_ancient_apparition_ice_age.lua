
boss_ancient_apparition_ice_age = class({})
LinkLuaModifier( "modifier_boss_ancient_apparition_frozen", "creature_ability/round_ancient_apparition/modifier_boss_ancient_apparition_frozen", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function boss_ancient_apparition_ice_age:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function boss_ancient_apparition_ice_age:OnSpellStart()
	if IsServer() then
		self.nChannelFX = ParticleManager:CreateParticle( "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/maiden_freezing_field_snow_arcana1.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		EmitSoundOn( "hero_Crystal.freezingField.wind", self:GetCaster() )
	end
end
-------------------------------------------------------------------------------

function boss_ancient_apparition_ice_age:OnChannelFinish( bInterrupted )
	if IsServer() then

		local  caster = self:GetCaster()

		ParticleManager:DestroyParticle( self.nChannelFX, false )
		StopSoundOn( "Hero_Crystal.FreezingField.Arcana", self:GetCaster() )
		EmitSoundOn( "Hero_Ancient_Apparition.IceBlast.Target", self:GetCaster() )
        self.frozen_duration = self:GetSpecialValueFor( "frozen_duration" )

        local explodeParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_ancient_apparition/ancient_apparition_ice_blast_explode.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(explodeParticle, 0, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(explodeParticle, 1, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(explodeParticle, 2, caster:GetAbsOrigin())
		ParticleManager:SetParticleControl(explodeParticle, 3, caster:GetAbsOrigin())

        if self:GetCaster() and self:GetCaster().vThornThinkers then
             

             print("self:GetCaster().vThornThinkers size"..#self:GetCaster().vThornThinkers)
             for _,thinker in pairs(self:GetCaster().vThornThinkers) do
 
                  local x = thinker:GetAbsOrigin().x + 2*(thinker:GetAbsOrigin().x - caster:GetAbsOrigin().x)      
                  local y = thinker:GetAbsOrigin().y + 2*(thinker:GetAbsOrigin().y - caster:GetAbsOrigin().y)      
                  local z = thinker:GetAbsOrigin().z
                  local enemies = FindUnitsInLine(self:GetCaster():GetTeamNumber(), thinker:GetAbsOrigin(), Vector(x,y,z), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE)     
                  for _,enemy in pairs(enemies) do
                  	  enemy.bBlockByThorn=true 
                  end
             end
        end

        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 18000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)		  
	    for _,enemy in pairs(enemies) do

           if enemy.bBlockByThorn == nil or enemy.bBlockByThorn==false then
           	   enemy:AddNewModifier(self:GetCaster(), self, "modifier_boss_ancient_apparition_frozen", {duration=self.frozen_duration})
           end
           enemy.bBlockByThorn=false
	    end
	end
end