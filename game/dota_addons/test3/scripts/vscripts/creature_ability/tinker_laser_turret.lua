function DealDamage( event )

  local caster      = event.caster
  local target      = event.target
  local ability     = event.ability

   ApplyDamage( {
      victim    = target,
      attacker  = caster,
      damage    = target:GetMaxHealth()*0.05,
      damage_type = DAMAGE_TYPE_PURE,
      damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
    } )

    -- Fire burn particle
    local pfx = ParticleManager:CreateParticle( event.particle_burn_name, PATTACH_ABSORIGIN, target )
    ParticleManager:SetParticleControlEnt( pfx, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true )
    ParticleManager:ReleaseParticleIndex( pfx )
end