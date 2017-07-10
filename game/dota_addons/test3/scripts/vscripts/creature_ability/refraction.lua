function StackRefraction(keys)
  local  caster = keys.caster
  local  ability = keys.ability
  --print("asdasdasdsa")
  local stack_count = caster:GetModifierStackCount("modifier_refraction_affect", ability)
  if stack_count==0 then
    ability.particle = ParticleManager:CreateParticle(keys.particle, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControlEnt(ability.particle, 1, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particle, 2, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
    ParticleManager:SetParticleControlEnt(ability.particle, 3, caster, PATTACH_POINT_FOLLOW, "attach_origin", caster:GetAbsOrigin(), true)
  end
  ability:ApplyDataDrivenModifier(caster, caster, "modifier_refraction_affect", {})
  caster:SetModifierStackCount("modifier_refraction_affect", ability, stack_count + 7)
end


function GiveInvulnerable(keys)
	 local  caster = keys.caster
     local  ability = keys.ability
     caster:AddNewModifier(nil,nil,"modifier_invulnerable",{duration=0.5})
end