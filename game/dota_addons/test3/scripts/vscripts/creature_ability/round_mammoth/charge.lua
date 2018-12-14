require("abilities/ability_generic")
require('quest_system')

function charge_unit( keys )
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability
        caster:StartGesture(ACT_DOTA_CAST_ABILITY_3)
        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("MyAbility_charge_time"), 
                function( )
                        if GameRules:IsGamePaused() == true then
                                return 0.1
                        end
                        --判断单位是否死亡，是否存在，是否被击晕
                        if caster:IsAlive() and IsValidEntity(caster) and not(caster:IsStunned()) then
                                
                                --不是死亡，存在这个单位，没被击晕，就运行这里面的内容
                                local caster_abs = caster:GetAbsOrigin()                --获取施法者的位置
                                local point_abs=target:GetAbsOrigin()                       --更新目标的绝对位置
                                local point=target:GetOrigin()
                                caster:SetForwardVector( ((point_abs - caster:GetOrigin()):Normalized()) )
                                if (point_abs - caster_abs):Length()>50 then        --当单位移动到距离指定地点小于50时不在进行移动

                                        local face = (point_abs - caster_abs):Normalized()
                                        local vec = face * 35.0
                                        caster:SetAbsOrigin(caster_abs + vec)

                                        return 0.01
                                else               
                                        caster:RemoveGesture(ACT_DOTA_CAST_ABILITY_3)                         
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
                                        caster:RemoveModifierByName("modifier_phased")
                                        --print("MyAbility_point Over")
                                        return nil
                                end

                        else
                                caster:RemoveModifierByName("modifier_phased")
                                --print("Caster is death or stunned")
                                return nil
                        end
                end, 0)
end

function charge_dot_over( keys )
    local target = keys.target
    --重置被攻击目标身上的伤害叠加
    ParticleManager:DestroyParticle(target.charge_dot_particle,true)
    ParticleManager:ReleaseParticleIndex(target.charge_dot_particle)
end


function charge_dot_damage( keys )
    local caster = keys.caster
    local target = keys.target
    local stacks = target:GetModifierStackCount("modifier_charge_dot",keys.ability)
    if GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound then
        if stacks>=2 and GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag==true then                                                 
          if target:IsRealHero() then
              local hero_name=target:GetName()
              local playerid= target:GetPlayerID()
              local playername=PlayerResource:GetPlayerName(playerid)
              Notifications:BottomToAll({hero = hero_name, duration = 4})
              Notifications:BottomToAll({text = playername.." ", duration = 4, continue = true})
              Notifications:BottomToAll({text = "#round9_acheivement_fail_note", duration = 4, style = {color = "Orange"}, continue = true})
          else
              Notifications:BottomToAll({text = "#round9_acheivement_fail_note", duration = 4, style = {color = "Orange"}})
          end
          QuestSystem:RefreshAchQuest("Achievement",0,1) 
          GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=false
        end
   end
  
  local dot_damage = 100
  if stacks>1 then
      dot_damage = 100*math.pow(1.8,stacks)
  else
      dot_damage = 100
  end

  local damageTable = {
         victim=target,
         attacker=caster,
         damage_type=DAMAGE_TYPE_PURE,
         damage=dot_damage
        }
    ApplyDamage(damageTable)
end