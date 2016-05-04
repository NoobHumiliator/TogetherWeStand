function concussive_shot_seek_target( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local particle_name = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
	local radius = ability:GetLevelSpecialValueFor( "launch_radius", ability:GetLevel() - 1 )
	local speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
	local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
	local targetType = DOTA_UNIT_TARGET_ALL  
	local targetFlag = DOTA_UNIT_TARGET_FLAG_NO_INVIS
	
	-- pick up x nearest target heroes and create tracking projectile targeting the number of targets
	local units = FindUnitsInRadius(
		caster:GetTeamNumber(), caster:GetAbsOrigin(), caster, radius, targetTeam,
		targetType, targetFlag, FIND_CLOSEST, false
	)
	local times=0
	-- Seek out target
	for k, v in pairs( units ) do
		local projTable = {
			EffectName = particle_name,
			Ability = ability,
			Target = v,
			Source = caster,
			bDodgeable = true,
			bProvidesVision = true,
			vSpawnOrigin = caster:GetAbsOrigin(),
			iMoveSpeed = speed,
			iVisionRadius = radius,
			iVisionTeamNumber = caster:GetTeamNumber(),
			iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_1
		}
		ProjectileManager:CreateTrackingProjectile( projTable )
		times=times+1
		if times>=20 then
		 break
		end
	end
end
