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
	local ability=keys.ability

	caster:RemoveModifierByNameAndCaster("modifier_supernova_buff_invulnerable", target)
    ParticleManager:DestroyParticle(target.bloodLinkParticle,false)
    ParticleManager:ReleaseParticleIndex(target.bloodLinkParticle)

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    for _,unit in pairs(units) do
         if not unit:HasModifier("modifier_supernova_egg_die_dot") then --蛋蛋爆炸,全团上Debuff
            ability:ApplyDataDrivenModifier(target, unit, "modifier_supernova_egg_die_dot", {Duration = 15}) 
            unit:SetModifierStackCount("modifier_charge_dot",ability,1)
         else
            local stack_count = target:GetModifierStackCount("modifier_supernova_egg_die_dot",ability)
            unit:RemoveModifierByName("modifier_supernova_egg_die_dot")
            ability:ApplyDataDrivenModifier(target, unit, "modifier_supernova_egg_die_dot", {Duration = 15}) 
            unit:SetModifierStackCount("modifier_charge_dot",ability,stack_count+1)
         end
    end



end


function DotDamage( keys )  --造成伤害
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability
	
	local stack_count = target:GetModifierStackCount("modifier_supernova_egg_die_dot",ability)
    local basic_damage = ability:GetLevelSpecialValueFor( "dot_basic_damage" , ability:GetLevel() - 1 )

    local damageTable = {
                        victim=unit,    --受到伤害的单位
                        attacker = caster,          --造成伤害的单位
                        damage = math.pow(basic_damage, stack_count),
                        damage_type = DAMAGE_TYPE_PURE,
                        damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
                        }
    ApplyDamage(damageTable)    --造成伤害

end