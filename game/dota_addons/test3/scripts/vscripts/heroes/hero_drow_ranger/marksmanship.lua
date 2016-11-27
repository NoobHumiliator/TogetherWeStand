require("util")

function SplitShotLaunch( keys )

	local caster = keys.caster
	local modifier_dmg_penalty = keys.modifier_dmg_penalty
	if caster:HasScepter() or (caster:GetOwnerEntity() and caster:GetOwnerEntity():HasScepter()) and not caster:HasModifier(modifier_dmg_penalty)  then

		local target = keys.target
        if target.marksmanshipMarkB~=nil and target.marksmanshipMarkB  then
           target.marksmanshipMarkB=nil
           return
        end
		local target_location = target:GetAbsOrigin()
		local caster_location = caster:GetAbsOrigin()
		local ability = keys.ability
		local ability_level = ability:GetLevel() - 1

		-- Ability variables
		local radius = ability:GetLevelSpecialValueFor("scepter_range", ability_level)
		local projectile_speed = ability:GetLevelSpecialValueFor("projectile_speed", ability_level)
		local split_shot_projectile = keys.split_shot_projectile

		local split_shot_targets = FindUnitsInRadius(caster:GetTeam(), target_location, nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

		-- Create projectiles for units that are not the casters current attack target
		for _,v in pairs(split_shot_targets) do
			if v ~= target then
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
				if target.marksmanshipMarkA~=nil and target.marksmanshipMarkA then
					v.marksmanshipMarkB=true
					target.marksmanshipMarkA=nil
				else
					v.marksmanshipMarkB=nil
				end
				ProjectileManager:CreateTrackingProjectile(projectile_info)
				break
			end
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
	target.marksmanshipMarkA=true
	caster:PerformAttack(target, true, true, true, true, false)
	caster:RemoveModifierByName(modifier_dmg_penalty)
end