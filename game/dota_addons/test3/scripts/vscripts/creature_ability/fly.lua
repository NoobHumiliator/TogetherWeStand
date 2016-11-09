require("abilities/ability_generic")


function fly_point( keys )
        local caster = keys.caster
        local point = keys.target_points[1]

        local radius = 400                --设置范围
        local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
        local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
        local flags = DOTA_UNIT_TARGET_FLAG_NONE

        --设置施法者的面向角度
        caster:SetForwardVector( ((point - caster:GetOrigin()):Normalized()) )

        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("MyAbility_point_time"), 
                function( )

                        --判断单位是否死亡，是否存在，是否被击晕
                        if caster:IsAlive() and IsValidEntity(caster) and not(caster:IsStunned()) then
                                
                                --不是死亡，存在这个单位，没被击晕，就运行这里面的内容
                                local caster_abs = caster:GetAbsOrigin()                --获取施法者的位置

                                if (point - caster_abs):Length()>50 then        --当单位移动到距离指定地点小于50时不在进行移动

                                        local face = (point - caster_abs):Normalized()
                                        local vec = face * 75.0
                                        caster:SetAbsOrigin(caster_abs + vec)

                                        return 0.01
                                else
                                        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, teams, types, flags, FIND_CLOSEST, true)

                                        --利用Lua的循环迭代，循环遍历每一个单位组内的单位
                                        for i,unit in pairs(targets) do
                                                local damageTable = {victim=unit,    --受到伤害的单位
                                                        attacker=caster,          --造成伤害的单位
                                                        damage=100,
                                                        damage_type=DAMAGE_TYPE_PURE}
                                                ApplyDamage(damageTable)    --造成伤害
                                        end

                                        caster:RemoveModifierByName("modifier_phased")
                                        return nil
                                end

                        else
                                caster:RemoveModifierByName("modifier_phased")
                                return nil
                        end
                end, 0)
end



function warlock_disappear( keys )
         local caster = keys.caster
        local casterOrigin=caster:GetOrigin()
        caster:SetOrigin(casterOrigin-Vector(0,0,1500)) 
        caster:ForceKill(true)
        GameRules:SendCustomMessage("#warlock_disappear_dbm", 0, 0)
        Notifications:TopToAll({ability= "warlock_disappear"})
        Notifications:TopToAll({text="#warlock_disappear_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})     
end





function fire_point( keys )
        local caster = keys.caster
        local point = keys.target_points[1]

        local radius = 650                --设置范围
        local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
        local types = DOTA_UNIT_TARGET_BASIC+DOTA_UNIT_TARGET_HERO
        local flags = DOTA_UNIT_TARGET_FLAG_NONE

        --设置施法者的面向角度
        caster:SetForwardVector( ((point - caster:GetOrigin()):Normalized()) )

        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("MyAbility_point_time"), 
                function( )

                        --判断单位是否死亡，是否存在，是否被击晕
                        if caster:IsAlive() and IsValidEntity(caster) and not(caster:IsStunned()) then
                                
                                --不是死亡，存在这个单位，没被击晕，就运行这里面的内容
                                local caster_abs = caster:GetAbsOrigin()                --获取施法者的位置

                                if (point - caster_abs):Length()>150 then        --当单位移动到距离指定地点小于50时不在进行移动

                                        local face = (point - caster_abs):Normalized()
                                        local vec = face * 150.0
                                        caster:SetAbsOrigin(caster_abs + vec)

                                        return 0.005
                                else
                                        local targets = FindUnitsInRadius(caster:GetTeam(), caster:GetOrigin(), nil, radius, teams, types, flags, FIND_CLOSEST, true)

                                        --利用Lua的循环迭代，循环遍历每一个单位组内的单位
                                        for i,unit in pairs(targets) do
                                                local damageTable = {victim=unit,    --受到伤害的单位
                                                        attacker=caster,          --造成伤害的单位
                                                        damage=100,
                                                        damage_type=DAMAGE_TYPE_PURE}
                                                ApplyDamage(damageTable)    --造成伤害
                                        end

                                        caster:RemoveModifierByName("modifier_phased")
                                        return nil
                                end

                        else
                                caster:RemoveModifierByName("modifier_phased")
                                return nil
                        end
                end, 0)
end




function water_grow( keys )
        local caster = keys.caster
        local ability = keys.ability
         if caster:GetContext("big_scale")==nil then    --dot计数器初始化
            caster:SetContextNum("big_scale", 1, 0) 
        end
        caster:SetContextNum("big_scale", caster:GetContext("big_scale") + 0.05, 0) 
        caster:SetModelScale(caster:GetContext("big_scale"))
        local rate=(caster:GetHealth()/caster:GetMaxHealth()) 
        local flDHPadjust=GameRules:GetGameModeEntity().CHoldoutGameMode.flDHPadjust  --难度修正
        local bonus_health = ability:GetSpecialValueFor("bonus_health")*flDHPadjust --获取新增的生命值
        caster:SetBaseMaxHealth(caster:GetMaxHealth()+bonus_health)
        caster:SetHealth(math.ceil(rate* caster:GetMaxHealth()))   
end

function water_fuse( keys )
        local caster = keys.caster
        local ability = keys.ability
         if caster:GetContext("big_scale")==nil then    --长大计数器
            caster:SetContextNum("big_scale", 1, 0) 
        end
        local rate=(caster:GetHealth()/caster:GetMaxHealth())
        local flDHPadjust=GameRules:GetGameModeEntity().CHoldoutGameMode.flDHPadjust  --难度修正
        local bonus_health = ability:GetSpecialValueFor("bonus_health")*flDHPadjust --获取新增的生命值
        caster:SetBaseMaxHealth(caster:GetMaxHealth()+bonus_health)
        caster:SetHealth(math.ceil(rate* caster:GetMaxHealth()))
        caster:SetContextNum("big_scale", caster:GetContext("big_scale") + 0.3, 0) 
        caster:SetModelScale(caster:GetContext("big_scale")) 
        local c_team = caster:GetTeam()         
        local radius = 210       
        local targets = FindUnitsInRadius(c_team, caster:GetOrigin() , nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
        for i,unit in pairs(targets) do
                 unitName = unit:GetUnitName() 
               if unit:GetUnitName()==("npc_majia_water_1") then
                unit:ForceKill(true)
                end
        end
          local targets = FindUnitsInRadius(c_team, caster:GetOrigin() , nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
        for i,unit in pairs(targets) do
                 unitName = unit:GetUnitName() 
                if unit:GetUnitName()==("npc_majia_water_1") then
                unit:ForceKill(true)
                end
        end
        Notifications:TopToAll({ability= "water_fuse"})
        Notifications:TopToAll({text="#fuse_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
end

function water_remove_self( keys )
        local caster = keys.caster
        caster.tiny_die_in_peace=true
        caster:RemoveAbility('water_die')
        if caster:FindAbilityByName("generic_gold_bag_fountain_500") then
        caster:RemoveAbility('generic_gold_bag_fountain_500')
        end
        if caster:FindAbilityByName("generic_gold_bag_fountain_200") then
        caster:RemoveAbility('generic_gold_bag_fountain_200')
        end
        if caster:FindAbilityByName("generic_gold_bag_fountain_100") then
        caster:RemoveAbility('generic_gold_bag_fountain_100')
        end
        if caster:FindAbilityByName("generic_gold_bag_fountain_50") then
        caster:RemoveAbility('generic_gold_bag_fountain_50')
        end
        local casterOrigin=caster:GetOrigin()
        caster:SetOrigin(casterOrigin-Vector(0,0,1500)) 
        caster:ForceKill(true)
        GameRules:SendCustomMessage("#envolveto3_dbm", 0, 0)
end

function tiny_wake( keys )
        local caster = keys.caster
        local c_team = caster:GetTeam()
        local targets = FindUnitsInRadius( c_team, caster:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )  --全地图所有单位                             
          for i,unit in pairs(targets) do
              local damageTable = {victim=unit,    --受到伤害的单位
                        attacker=caster,          --造成伤害的单位
                        damage=100000,
                       damage_type=DAMAGE_TYPE_PURE}
                       ApplyDamage(damageTable)    --造成伤害
         end
         local  wp = Entities:FindByName( nil, "waypoint_middle1" )
         local entUnit = CreateUnitByName( "npc_dota_warlock_boss_2", wp:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS )
         Notifications:TopToAll({ability= "tiny_wake"})
         Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#tiny_wake_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})    
end



function tiny_hurt_1( keys )
        local caster = keys.caster
        caster:SetHealth(3000)
end

function tiny_hurt_2( keys )
        local caster = keys.caster
        caster:SetHealth(5000)
end

function tiny_hurt_3( keys )
        local caster = keys.caster
        caster:SetHealth(11000)
end

function tiny_hurt_4( keys )
        local caster = keys.caster
        caster:SetHealth(12000)
        caster:FindAbilityByName("tiny_splitter"):SetLevel(2)
end

function tiny_hurt_5( keys )
        local caster = keys.caster
        caster:SetHealth(18000)
        caster:FindAbilityByName("tiny_splitter"):SetLevel(3)
end

function warlock_rain( keys )
        local caster = keys.caster
        caster:FindAbilityByName("rain_chaos"):SetLevel(3)
end


function tiny_eat(keys)
        local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
        if #targets > 0 then
           for i,unit in pairs(targets) do                 
               if unit:GetUnitName()==("npc_dota_tiny_1") or unit:GetUnitName()==("npc_dota_tiny_2") or unit:GetUnitName()==("npc_dota_tiny_3") or unit:GetUnitName()==("npc_dota_tiny_4") or unit:GetUnitName()==("npc_dota_tiny_5") then       
                  unit:SetHealth(unit:GetHealth()+unit:GetMaxHealth()*0.025)  
               end 
           end
       end     
end
function tiny_collapse(keys)
        local caster = keys.caster
        local collapse_hurt=caster:GetMaxHealth()*0.08
        if (caster:GetHealth()-collapse_hurt)<1 then
            caster:ForceKill(true)
        else
        caster:SetHealth(caster:GetHealth()-collapse_hurt)
        end
end




function charge_unit( keys )
        local caster = keys.caster
        local target = keys.target
        local ability = keys.ability

        GameRules:GetGameModeEntity():SetContextThink(DoUniqueString("MyAbility_charge_time"), 
                function( )

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
                                else                                            --如果距离小于50，停止冲锋，处理DOT
                                        if caster:HasModifier("modifier_charge_dur_act") then
                                            caster:RemoveModifierByName("modifier_charge_dur_act")  --停止冲锋动画
                                        else
                                        end
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
          GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=false
        end
   end
  local flDDadjust=GameRules:GetGameModeEntity().CHoldoutGameMode.flDDadjust
  local dot_damage = 100*stacks*stacks*flDDadjust --物理伤害的难度修正
  local damageTable = {victim=target,
  attacker=caster,
  damage_type=DAMAGE_TYPE_PURE,
  damage=dot_damage}
    --造成伤害
    ApplyDamage(damageTable)
    --print("damage is"..dot_damage)
end

function remove_wake_ability(keys)
    local argets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
    local tiny_5=nil
      for i,nit in pairs(argets) do
           if nit:GetUnitName()==("npc_dota_tiny_5") then
           tiny_5=nit
           end
      end
    if tiny_5 and tiny_5:FindAbilityByName("tiny_wake") then
       tiny_5:RemoveAbility("tiny_wake")
    end  
end