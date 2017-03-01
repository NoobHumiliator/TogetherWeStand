
function Aftershock( keys )
	local caster = keys.caster
	local target = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local cast_ability = keys.event_ability
	local aftershock_particle = keys.aftershock_particle
	--local aftershock_sound = keys.aftershock_sound
    --print("cast_ability"..cast_ability:GetAbilityName())

    local ability_exempt_table = {}
    ability_exempt_table["shredder_chakram"]=true
    ability_exempt_table["shredder_chakram_2"]=true

    local chance_pass=true  --某些技能概率不通过

    if RandomInt(0,100)<35 and ability_exempt_table[cast_ability:GetAbilityName()] then  --35% 概率不通过
       chance_pass=false 
    end

	-- Parameters
	local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
	local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
	local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
    if cast_ability and cast_ability:GetManaCost( cast_ability:GetLevel() - 1 ) > 0 and cast_ability:GetCooldown( cast_ability:GetLevel() - 1 ) > 1.01  and chance_pass then
	      local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
	      print(#enemies)	
	     -- local after_shock_particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earthshaker/earthshaker_loadout.vpcf", PATTACH_ABSORIGIN_FOLLOW, cater)
	      --ParticleManager:SetParticleControl(after_shock_particle, 1, caster:GetAbsOrigin())
	      ability:ApplyDataDrivenModifier(caster, caster, "modifier_shock_particle", {})
	      for _,enemy in pairs(enemies) do		
		  -- Fire impact particle	
		  enemy:AddNewModifier(caster, ability, "modifier_stunned", {duration = stun_duration})
		  -- Apply damage
		  ApplyDamage({attacker = caster, victim = enemy, ability = ability, damage = damage, damage_type = ability:GetAbilityDamageType()})
	      end      
	end
end


