require("util")

function SplitShotLaunch( keys )

	local caster = keys.caster
	if caster:HasScepter() or (caster:GetOwnerEntity() and caster:GetOwnerEntity():HasScepter() )  then
		local target = keys.target
		local target_location = target:GetAbsOrigin()
		local caster_location = caster:GetAbsOrigin()
		local ability = keys.ability
		local ability_level = ability:GetLevel() - 1

		local attack_target = caster:GetAttackTarget()

		-- Ability variables
		local radius = ability:GetLevelSpecialValueFor("scepter_range", ability_level)
		local max_targets = ability:GetLevelSpecialValueFor("split_count_scepter", ability_level)-1
		local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
		local split_shot_projectile = keys.split_shot_projectile

		local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), target_location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

		-- Create projectiles for units that are not the casters current attack target
		for _,v in pairs(split_shot_targets) do
			if v ~= attack_target then
				local projectile_info = 
				{
					EffectName = split_shot_projectile,
					Ability = ability,
					vSpawnOrigin = target_location,
					Target = v,
					Source = target,
					bHasFrontalCone = false,
					iMoveSpeed = projectile_speed,
					bReplaceExisting = false,
					bProvidesVision = false
				}
				local time= (target_location-v:GetAbsOrigin()):Length() /projectile_speed
				ProjectileManager:CreateTrackingProjectile(projectile_info)
				max_targets = max_targets - 1
			end
			-- If we reached the maximum amount of targets then break the loop
			if max_targets == 0 then break end
		end
	end
end


function MarksmanshipHit( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local modifier_dmg_penalty = keys.modifier_dmg_penalty

	-- Attack the target
	ability:ApplyDataDrivenModifier(caster, caster, modifier_dmg_penalty, {})
	caster:PerformAttack(target, true, true, true, true, false)
	caster:RemoveModifierByName(modifier_dmg_penalty)
end