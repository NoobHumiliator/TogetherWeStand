require( "libraries/notifications")

function MissileStack(keys)
  local  caster = keys.caster
  local  ability = keys.ability
  local  target= keys.target
  local damage = ability:GetLevelSpecialValueFor("damage", ability:GetLevel()-1)


  local stack_count = target:GetModifierStackCount("modifier_missile_stack", ability)
  ability:ApplyDataDrivenModifier(caster, target, "modifier_missile_stack", {duration=8})
  target:SetModifierStackCount("modifier_missile_stack", ability, stack_count + 1)
  
  local DamageInfo =
  {
      victim = target,
      attacker = caster,
      ability = ability,
      damage = damage*(stack_count+1), --每层增加500点伤害
      damage_type = DAMAGE_TYPE_PURE
  }
  ApplyDamage( DamageInfo )

end


function MissileSeekTarget( keys )
  -- Variables
  local caster = keys.caster
  local ability = keys.ability
  local particle_name = "particles/units/heroes/hero_tinker/tinker_missile.vpcf"
  local radius = ability:GetLevelSpecialValueFor( "launch_radius", ability:GetLevel() - 1 )
  local speed = ability:GetLevelSpecialValueFor( "speed", ability:GetLevel() - 1 )
  local targetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY
  local targetType = DOTA_UNIT_TARGET_ALL  
  local targetFlag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
  
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
    if times>=15 then
     break
    end
  end
end


function MissileDBM( keys )
  Notifications:BossAbilityDBM("tinker_boss_heatmissile")
end