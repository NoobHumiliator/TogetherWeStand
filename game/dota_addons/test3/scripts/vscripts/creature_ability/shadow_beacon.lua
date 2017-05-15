function ShadowBeaconActive( keys )
	local caster = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel()-1
    local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
    local caster_location=caster:GetAbsOrigin()

    local allies = FindUnitsInRadius(caster:GetTeamNumber(), caster_location, nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)

    for _,ally in pairs(allies) do
        if ally~=caster then
            caster:EmitSound("Hero_Dazzle.Shadow_Wave")
        	local heal = ally:GetMaxHealth()*0.3
        	ally:Heal(heal,caster)
        	local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dazzle/dazzle_shadow_wave.vpcf", PATTACH_CUSTOMORIGIN, caster)
    		ParticleManager:SetParticleControlEnt(particle, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster_location, true)
    		ParticleManager:SetParticleControlEnt(particle, 1, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
        end
    end

end
