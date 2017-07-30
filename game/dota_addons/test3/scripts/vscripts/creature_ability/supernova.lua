function LinkToCaster( keys )  --向施法者连一条输血线
	local target=keys.target
	local caster=keys.caster
    local ability=keys.ability

	local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
    target.bloodLinkParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(target.bloodLinkParticle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ability:ApplyDataDrivenModifier(target, caster, "modifier_supernova_buff_invulnerable", {})
end



function OnDestroyEgg( keys )  --取消血线，移除BUFF
	local target=keys.target
	local caster=keys.caster

	caster:RemoveModifierByNameAndCaster("modifier_supernova_buff_invulnerable", target)
    ParticleManager:DestroyParticle(target.bloodLinkParticle,false)
    ParticleManager:ReleaseParticleIndex(target.bloodLinkParticle)

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    for _,unit in pairs(units) do
         if not unit:HasModifier("modifier_supernova_egg_die_dot") then
            ability:ApplyDataDrivenModifier(target, unit, modifier_name, {Duration = 15})  --蛋蛋爆炸,全团上Debuff
         else

         end
    end



end


function DotDamage( keys )  --取消血线，移除BUFF
	local target = 
	 if not target:HasModifier("modifier_charge_dot") then
	        AddModifier(caster, target, ability, "modifier_charge_dot", nil)
	        target:SetModifierStackCount("modifier_charge_dot",keys.ability,1)
	         local particle= ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf",PATTACH_OVERHEAD_FOLLOW,target)
	               ParticleManager:SetParticleControl(particle, 1, Vector(0,1,0))
	               target.charge_dot_particle= particle                                                                          
	      else
	       -- 获取玩家的Modifier叠加数
	      local bullets_count = target:GetModifierStackCount("modifier_charge_dot",keys.ability)
	      --print("stack_count"..bullets_count)
	      bullets_count=bullets_count+1
	      target:RemoveModifierByName("modifier_charge_dot")
	      AddModifier(caster, target, ability, "modifier_charge_dot", nil)
	      target:SetModifierStackCount("modifier_charge_dot",keys.ability,bullets_count)
	      local particle= ParticleManager:CreateParticle("particles/units/heroes/hero_batrider/batrider_stickynapalm_stack.vpcf",PATTACH_OVERHEAD_FOLLOW,target)
	      ParticleManager:SetParticleControl(particle, 1, Vector(0,bullets_count,0)) 
	      target.charge_dot_particle= particle
	      print("stack_count new"..target:GetModifierStackCount("modifier_charge_dot",keys.ability))                                                
	 end
end