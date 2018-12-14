function IsNearFireCheck( event )
	local caster = event.caster
	local ability = event.ability
	if ability then
		local target= event.target
		local mana=target:GetMana()
		local cancel_range = ability:GetLevelSpecialValueFor( "cancel_range" , ability:GetLevel() - 1 )
		local damage_increase=ability:GetLevelSpecialValueFor( "damage_increase" , ability:GetLevel() - 1 )
		local range_increase=ability:GetLevelSpecialValueFor( "radius_increase" , ability:GetLevel() - 1 )
		if target.dark_twin_debuff_range==nil or target.dark_twin_debuff_range==0  then
			target.dark_twin_debuff_range=ability:GetLevelSpecialValueFor( "initial_radius" , ability:GetLevel() - 1 )
		end
		if target.dark_twin_debuff_damage==nil or target.dark_twin_debuff_damage==0  then
			target.dark_twin_debuff_damage=ability:GetLevelSpecialValueFor( "initial_damage" , ability:GetLevel() - 1 )
		end

		local dark_twin_enemies= FindUnitsInRadius( DOTA_TEAM_BADGUYS, target:GetOrigin(), nil, cancel_range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )  
		for _,enemy in pairs(dark_twin_enemies) do
			if enemy:IsAlive() then
				if enemy:GetUnitName()=="npc_dota_boss_fire_twin" and not enemy:HasModifier("modifier_regen_health") then 
					target:RemoveModifierByName("modifier_dark_twin_debuff")
				end
			end
		end
		local friends= FindUnitsInRadius( target:GetTeam(), target:GetOrigin(), nil, target.dark_twin_debuff_range , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,freind in pairs(friends) do
		   local damage_table = {}
		   damage_table.attacker = caster
		   damage_table.victim = freind
		   damage_table.ability = ability
		   damage_table.damage_type = ability:GetAbilityDamageType()
		   damage_table.damage = target.dark_twin_debuff_damage
		   ApplyDamage(damage_table)
		if mana-target.dark_twin_debuff_damage*0.2<0 then
			target:SetMana(0)
		else
			target:SetMana(mana-target.dark_twin_debuff_damage*0.2)
		end
		local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_dark_seer/dark_seer_ion_shell_damage.vpcf", PATTACH_POINT_FOLLOW, freind) 
		ParticleManager:SetParticleControlEnt(particle, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true) 
		ParticleManager:SetParticleControlEnt(particle, 1, freind, PATTACH_POINT_FOLLOW, "attach_hitloc", freind:GetAbsOrigin(), true)
		ParticleManager:ReleaseParticleIndex(particle)
	    end
	    target.dark_twin_debuff_damage=target.dark_twin_debuff_damage*damage_increase
	    target.dark_twin_debuff_range=target.dark_twin_debuff_range+range_increase
     end
end


function StopSound( keys )
	local target = keys.target
	local sound = keys.sound
	target.dark_twin_debuff_range=0
	target.dark_twin_debuff_damage=0
	StopSoundEvent(sound, target)
end