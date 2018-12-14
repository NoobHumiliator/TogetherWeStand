function volly(args)
	local caster = args.caster
	local info = 
	   {
	    Ability = args.ability,
        EffectName = args.EffectName,
        iMoveSpeed = args.MoveSpeed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = args.FixedDistance,
        fStartRadius = args.StartRadius,
        fEndRadius = args.EndRadius,
        Source = args.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC+ DOTA_UNIT_TARGET_OTHER,
        bDeleteOnHit = true,
        vVelocity = 0.0,
	   }
	  for i=-40,40,20 do
          info.vSpawnOrigin = caster:GetAbsOrigin()+RotatePosition(Vector(0,0,0), QAngle(0,90,0), caster:GetForwardVector()) * i*10
		  info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i,0), caster:GetForwardVector()) * args.MoveSpeed
	  	projectile = ProjectileManager:CreateLinearProjectile(info)
  	  end
end