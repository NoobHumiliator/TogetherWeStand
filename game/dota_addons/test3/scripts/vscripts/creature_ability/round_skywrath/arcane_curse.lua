require('libraries/notifications')
require("abilities/ability_generic")

function AddStack( keys )
     local caster = keys.caster
     local target = nil
     if keys.unit then
         target = keys.unit
     else
         target = keys.attacker 
     end
     local ability = keys.ability     
     if not target:HasModifier("modifier_arcane_curse_debuff_stack") then
         AddModifier(caster, target, ability, "modifier_arcane_curse_debuff_stack", nil)
         target.safe_to_remove_curse_debuff=false
         target:SetModifierStackCount("modifier_arcane_curse_debuff_stack",keys.ability,1)
         local particle= ParticleManager:CreateParticle("particles/hw_fx/candy_carrying_stack.vpcf",PATTACH_OVERHEAD_FOLLOW,target)
         ParticleManager:SetParticleControl(particle, 2, Vector(0,1,0))
         target.arcane_stack_particle= particle
         target.arcane_stacks=1                                                                          
     else
         -- 获取玩家的Modifier叠加数
         local bullets_count = target:GetModifierStackCount("modifier_arcane_curse_debuff_stack",keys.ability)
         --print("stack_count"..bullets_count)
         bullets_count=bullets_count+1

         if  bullets_count>8  and GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag==true then
              if target:IsRealHero() then
                QuestSystem:RefreshAchQuest("Achievement",0,1) 
                GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=false
                local hero_name=target:GetName()
                local playerid= target:GetPlayerID()
                local playername=PlayerResource:GetPlayerName(playerid)
                Notifications:BottomToAll({hero = hero_name, duration = 4})
                Notifications:BottomToAll({text = playername.." ", duration = 4, continue = true})
                Notifications:BottomToAll({text = "#round_dragon_acheivement_fail_note", duration = 4, style = {color = "Orange"}, continue = true})
              end
         end

         target.safe_to_remove_curse_debuff=true
         target:RemoveModifierByName("modifier_arcane_curse_debuff_stack")
         AddModifier(caster, target, ability, "modifier_arcane_curse_debuff_stack", nil)
         target.safe_to_remove_curse_debuff=false
         target:SetModifierStackCount("modifier_arcane_curse_debuff_stack",keys.ability,bullets_count)
         local particle= ParticleManager:CreateParticle("particles/hw_fx/candy_carrying_stack.vpcf",PATTACH_OVERHEAD_FOLLOW,target)
         if bullets_count<10 then
          ParticleManager:SetParticleControl(particle, 2, Vector(0,bullets_count,0))
         else
          ParticleManager:SetParticleControl(particle, 2, Vector(math.floor(bullets_count/10),bullets_count-math.floor(bullets_count/10)*10,0))
         end
         target.arcane_stack_particle= particle
         target.arcane_stacks=target:GetModifierStackCount("modifier_arcane_curse_debuff_stack",keys.ability)
    end   
end


function StackOverDamage( keys )
     local caster = keys.caster
     local target = keys.target
     local ability = keys.ability
     --print("target name is"..target:GetUnitName()) 
     ParticleManager:DestroyParticle(target.arcane_stack_particle,true)
     ParticleManager:ReleaseParticleIndex(target.arcane_stack_particle)
     if target.safe_to_remove_curse_debuff and target.safe_to_remove_curse_debuff==true then
       else
        target:RemoveModifierByName("modifier_item_blade_mail_reflect")
       local damageTable = {victim=target,
                           attacker=caster,
                           damage_type=DAMAGE_TYPE_PURE,
                           damage=1.4^target.arcane_stacks*60}
           ApplyDamage(damageTable)
       local particleName = "particles/econ/items/lanaya/lanaya_epit_trap/templar_assassin_epit_trap_explode.vpcf"
       local particle = ParticleManager:CreateParticle( particleName, PATTACH_ABSORIGIN_FOLLOW, target )
       target:EmitSound("Hero_Nevermore.Shadowraze")                 
       target.arcane_stacks=0
     end
end



function ForceExplode(keys)
     local caster = keys.caster
     local ability = keys.ability
     caster:RemoveModifierByName("modifier_razor_eye_of_the_storm_armor")
     Notifications:TopToAll({ability= "boss_arcane_curse_explode_datadriven"})
     Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#boss_arcane_curse_explode_datadriven_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
     local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, caster:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
     for _,enemy in pairs(enemies) do
         if enemy:HasModifier("modifier_arcane_curse_debuff_stack") then
            while enemy:HasModifier("modifier_razor_eye_of_the_storm") do
              enemy:RemoveModifierByName("modifier_razor_eye_of_the_storm")  
            end
            enemy:RemoveModifierByName("modifier_abaddon_borrowed_time")
            enemy:RemoveModifierByName("modifier_templar_assassin_refraction_absorb")
            enemy:RemoveModifierByName("modifier_arcane_curse_debuff_stack")
         end
     end
end