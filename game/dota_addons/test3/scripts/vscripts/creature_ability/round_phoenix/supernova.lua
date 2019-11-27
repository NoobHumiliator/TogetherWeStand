require('libraries/notifications')
require('quest_system')


--最大叠加层数
max_stack_number=0


function LinkToCaster( keys )  --向施法者连一条输血线
	local target=keys.target
	local caster=keys.caster
    local ability=keys.ability

	local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
    target.bloodLinkParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(target.bloodLinkParticle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
end



function OnDestroyEgg( keys )  --取消血线，移除BUFF

	local caster=keys.caster
	local ability=keys.ability

    ParticleManager:DestroyParticle(caster.bloodLinkParticle,true)
    ParticleManager:ReleaseParticleIndex(caster.bloodLinkParticle)

    local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for _,unit in pairs(units) do
         if not unit:HasModifier("modifier_supernova_egg_die_dot") then --蛋蛋爆炸,全团上Debuff
            ability:ApplyDataDrivenModifier(caster, unit, "modifier_supernova_egg_die_dot", {Duration = 15})
            unit:SetModifierStackCount("modifier_supernova_egg_die_dot",ability,1)
            if max_stack_number==0 then
                QuestSystem:RefreshAchQuest("Achievement",1,6)
            end
         else
            local stack_count = unit:GetModifierStackCount("modifier_supernova_egg_die_dot",ability)
            unit:RemoveModifierByName("modifier_supernova_egg_die_dot")
            ability:ApplyDataDrivenModifier(caster, unit, "modifier_supernova_egg_die_dot", {Duration = 15})
            unit:SetModifierStackCount("modifier_supernova_egg_die_dot",ability,stack_count+1)
            if stack_count+1>max_stack_number then
               QuestSystem:RefreshAchQuest("Achievement",stack_count+1,6)
               max_stack_number=stack_count+1
            end
            if stack_count+1>=6 then
               GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=true
            end
         end
    end
    caster:EmitSound("Hero_Phoenix.SuperNova.Explode")


    -- 凤凰蛋爆炸 粒子特效
    local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
    local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN, caster )
    ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true )
    ParticleManager:SetParticleControlEnt( pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )

end



function DotDamage( keys )  --造成伤害
	local target = keys.target
	local caster = keys.caster
	local ability = keys.ability

	local stack_count = target:GetModifierStackCount("modifier_supernova_egg_die_dot",ability)
    local basic_damage = ability:GetSpecialValueFor("dot_basic_damage")

    local damageTable = {
                            victim=target,     --受到伤害的单位
                            attacker = caster, --造成伤害的单位
                            damage = math.pow(2, stack_count)*basic_damage,
                            damage_type = DAMAGE_TYPE_PURE,
                            damage_flags = DOTA_DAMAGE_FLAG_NONE
                        }
    ApplyDamage(damageTable)    --造成伤害

end