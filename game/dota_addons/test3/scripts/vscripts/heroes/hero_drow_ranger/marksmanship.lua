require("util")

function SplitShotLaunch( keys )

	local caster = keys.caster
	local modifier_dmg_penalty = keys.modifier_dmg_penalty
	if ( caster and caster:HasScepter() ) or (caster:GetOwnerEntity().HasScepter and caster:GetOwnerEntity():HasScepter()) and not caster:HasModifier(modifier_dmg_penalty)  then

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
		local split_count_scepter = ability:GetLevelSpecialValueFor("split_count_scepter", ability_level) --分裂数量

		local split_shot_projectile = keys.split_shot_projectile

		if caster:IsRangedAttacker() then
		  split_shot_projectile = caster:GetRangedProjectileName()  --获取英雄的攻击例子特效
		end
        
        local count=0;
		--print("split_shot_projectile"..split_shot_projectile)

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
				ProjectileManager:CreateTrackingProjectile(projectile_info)
                count=count+1
                if count>=split_count_scepter then --如果达到上限
                	break
                end
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
	ability:ApplyDataDrivenModifier(caster, caster, modifier_dmg_penalty, {})  --减攻击力
	caster:RemoveModifierByName("modifier_marksmanship_passive_datadriven")  --移除分裂

	caster:PerformAttack(target, true, true, true, true, false,false,false)
	ability:ApplyDataDrivenModifier(caster, caster, "modifier_marksmanship_passive_datadriven", {}) --添加回分裂
	
	caster:RemoveModifierByName(modifier_dmg_penalty)  --恢复攻击力
end