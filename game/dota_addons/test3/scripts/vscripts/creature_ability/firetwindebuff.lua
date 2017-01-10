function IsNearDarkCheck( event )
	local caster = event.caster
	local ability = event.ability
	local target= event.target
	local mana=target:GetMana()
	if ability then
		local cancel_range = ability:GetLevelSpecialValueFor( "cancel_range" , ability:GetLevel() - 1 )
		local damage_increase=ability:GetLevelSpecialValueFor( "damage_increase" , ability:GetLevel() - 1 )
		local range_increase=ability:GetLevelSpecialValueFor( "radius_increase" , ability:GetLevel() - 1 )
		if target.fire_twin_debuff_range==nil or target.fire_twin_debuff_range==0  then
			target.fire_twin_debuff_range=ability:GetLevelSpecialValueFor( "initial_radius" , ability:GetLevel() - 1 )
		end
		if target.fire_twin_debuff_damage==nil or target.fire_twin_debuff_damage==0  then
			target.fire_twin_debuff_damage=ability:GetLevelSpecialValueFor( "initial_damage" , ability:GetLevel() - 1 )
		end
		local fire_twin_enemies= FindUnitsInRadius( DOTA_TEAM_BADGUYS, target:GetOrigin(), nil, cancel_range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
		for _,enemy in pairs(fire_twin_enemies) do
			if enemy:IsAlive() then
				if enemy:GetUnitName()=="npc_dota_boss_dark_twin" and not enemy:HasModifier("modifier_regen_health") then 
					target:RemoveModifierByName("modifier_fire_twin_debuff")
				end
			end
		end
		local friends= FindUnitsInRadius( target:GetTeam(), target:GetOrigin(), nil, target.fire_twin_debuff_range , DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		for _,freind in pairs(friends) do
		   local damage_table = {}
		   damage_table.attacker = caster
		   damage_table.victim = freind
		   damage_table.ability = ability
		   damage_table.damage_type = ability:GetAbilityDamageType()
		   damage_table.damage = target.fire_twin_debuff_damage
	       ApplyDamage(damage_table)
		   if mana-target.fire_twin_debuff_damage*0.2<0 then
			  target:SetMana(0)
		   else
			  target:SetMana(mana-target.fire_twin_debuff_damage*0.1)
		   end
		   local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/emberspirit_flame_shield_aoe_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, freind)
	        --ability:ApplyDataDrivenModifier(target, freind, "modifier_fire_twin_debuff_aura_particle", {})
	     end
	    --print("damage is"..target.fire_twin_debuff_damage)
	     target.fire_twin_debuff_damage=target.fire_twin_debuff_damage*damage_increase
	     target.fire_twin_debuff_range=target.fire_twin_debuff_range+range_increase
	end
end


function StopSound( keys )
	local target = keys.target
	local sound = keys.sound
	target.fire_twin_debuff_range=0
	target.fire_twin_debuff_damage=0
	StopSoundEvent(sound, target)
end