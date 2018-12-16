boss_ancient_apparition_ice_thorn = class({})
LinkLuaModifier( "modifier_boss_ancient_apparition_ice_thorn", "creature_ability/round_ancient_apparition/modifier_boss_ancient_apparition_ice_thorn", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_ancient_apparition_ice_thorn_thinker", "creature_ability/round_ancient_apparition/modifier_boss_ancient_apparition_ice_thorn_thinker", LUA_MODIFIER_MOTION_NONE )

------------------------------------------------------------------

function boss_ancient_apparition_ice_thorn:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function boss_ancient_apparition_ice_thorn:OnSpellStart()

    
	if IsServer() then
		EmitSoundOn( "Hero_Tusk.IceShards.Projectile", self:GetCaster() )

        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetAbsOrigin(), nil, 18000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)		  
	    for _,enemy in pairs(enemies) do

            local vLoc1=enemy:GetOrigin()
            local vLoc2=Vector(enemy:GetOrigin().x+RandomInt(-600, 600),enemy:GetOrigin().y+RandomInt(-600, 600),enemy:GetOrigin().z)
			local vLoc3=Vector(enemy:GetOrigin().x+RandomInt(-600, 600),enemy:GetOrigin().y+RandomInt(-600, 600),enemy:GetOrigin().z)

		    CreateModifierThinker( self:GetCaster(), self, "modifier_boss_ancient_apparition_ice_thorn_thinker", {}, vLoc1, self:GetCaster():GetTeamNumber(), false )
            CreateModifierThinker( self:GetCaster(), self, "modifier_boss_ancient_apparition_ice_thorn_thinker", {}, vLoc2,self:GetCaster():GetTeamNumber(), false )
            --CreateModifierThinker( self:GetCaster(), self, "modifier_boss_ancient_apparition_ice_thorn_thinker", {}, vLoc3,self:GetCaster():GetTeamNumber(), false )
	    
	    end
	end
end

------------------------------------------------------------------
