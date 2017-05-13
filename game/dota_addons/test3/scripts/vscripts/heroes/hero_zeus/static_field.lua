function StaticField(keys)
	local caster = keys.caster
	local ability = keys.ability
	local radius = ability:GetLevelSpecialValueFor("radius", (ability:GetLevel() -1))
	local damage_health_pct = ability:GetLevelSpecialValueFor("damage_health_pct", (ability:GetLevel() -1))/100
    local cast_ability = keys.event_ability
    if caster:HasAbility("special_bonus_unique_zeus") then
       if caster:FindAbilityByName("special_bonus_unique_zeus"):GetLevel()>0 then  --如果有宙斯天赋 
       	  damage_health_pct=damage_health_pct+0.02                                 --加百分之2伤害
       end
    end

	
    local ability_exempt_table = {}
    ability_exempt_table["shredder_chakram"]=true
    ability_exempt_table["shredder_chakram_2"]=true

    local chance_pass=true  --某些技能概率不通过

    if RandomInt(0,100)<25 and ability_exempt_table[cast_ability:GetAbilityName()] then  --25% 概率不通过
       chance_pass=false 
    end
    
	if cast_ability and cast_ability:GetManaCost( cast_ability:GetLevel() - 1 ) > 0 and cast_ability:GetCooldown( cast_ability:GetLevel() - 1 ) > 0.05  and chance_pass then
		local units = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, radius, ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(), 0, 0, false)
		for i,unit in ipairs(units) do
			local particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, unit)
			ParticleManager:SetParticleControl(particle,0,unit:GetAbsOrigin())
			EmitSoundOn(keys.sound, unit)
			ApplyDamage({victim = unit, attacker = caster, damage = unit:GetHealth() * damage_health_pct, damage_type = ability:GetAbilityDamageType(), ability = ability })
		end
	end
end