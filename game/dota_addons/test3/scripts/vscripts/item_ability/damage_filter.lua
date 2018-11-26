 --damageTable.damagetype_const
--1 physical
--2 magical
--4 pure

sp_exempt_table = {}
sp_exempt_table["necrolyte_reapers_scythe_datadriven"]=true
sp_exempt_table["huskar_life_break"]=true
sp_exempt_table["self_huskar_life_break"]=true
sp_exempt_table["zuus_static_field"]=true
sp_exempt_table["death_prophet_spirit_siphon"]=true
sp_exempt_table["elder_titan_earth_splitter"]=true
sp_exempt_table["winter_wyvern_arctic_burn"]=true
sp_exempt_table["doom_bringer_infernal_blade"]=true
sp_exempt_table["phoenix_sun_ray"]=true
sp_exempt_table["abyssal_underlord_firestorm"]=true
sp_exempt_table["zuus_static_field_datadriven"]=true
sp_exempt_table["spectre_dispersion_datadriven"]=true
sp_exempt_table["item_blade_mail"]=true
sp_exempt_table["witch_doctor_maledict"]=true

re_table={} --反伤类技能  折射单独处理
re_table["tiny_craggy_exterior"]=true
re_table["bristleback_quill_spray"]=true
re_table["bristleback_bristleback"]=true
re_table["centaur_return_datadriven"]=true
re_table["centaur_return"]=true
re_table["spectre_dispersion"]=true
re_table["viper_corrosive_skin"]=true
re_table["razor_unstable_current"]=true
re_table["item_blade_mail"]=true
re_table["axe_counter_helix_datadriven"]=true
re_table["axe_counter_helix"]=true


function CHoldoutGameMode:DamageFilter(damageTable)
  
   --DeepPrint( damageTable )
   if damageTable and damageTable.entindex_attacker_const then
	  local attacker = EntIndexToHScript(damageTable.entindex_attacker_const)
	  local victim = EntIndexToHScript(damageTable.entindex_victim_const)
	  if  attacker and attacker:GetTeam()==DOTA_TEAM_GOODGUYS then
          local playerid=attacker:GetPlayerOwnerID()             
          local hero = PlayerResource:GetSelectedHeroEntity( playerid )
	        if damageTable.entindex_inflictor_const ~=nil then --有明确来源技能
	           local ability=EntIndexToHScript(damageTable.entindex_inflictor_const)
             --print("attacker:GetPlayerOwnerID()"..attacker:GetPlayerOwnerID())
             --print("Ability Name: "..ability:GetAbilityName().." Attacker: "..attacker:GetUnitName() )
	           if ability and hero and hero.sp~=nil and  damageTable.damagetype_const==2  and  not sp_exempt_table[ability:GetAbilityName()]  then
	           	 if ability:IsToggle() or ability:IsPassive() then
	              damageTable.damage=damageTable.damage*(1+hero.sp*0.3*hero:GetIntellect()/100)  
	             else
	              damageTable.damage=damageTable.damage*(1+hero.sp*hero:GetIntellect()/100)
	             end
	           end
             if  ability and ability.GetAbilityName and hero and re_table[ability:GetAbilityName()]~=nil and re_table[ability:GetAbilityName()] then
                if hero.pysical_return~=nil and damageTable.damagetype_const==1 then --物理类反伤处理技能
                  damageTable.damage=damageTable.damage*(1+hero.pysical_return*hero:GetStrength()/100)
                end
                if hero.magical_return~=nil and damageTable.damagetype_const==2 then --魔法类反伤处理技能
                  damageTable.damage=damageTable.damage*(1+hero.magical_return*hero:GetStrength()/100)
                end
                if hero.pure_return~=nil and damageTable.damagetype_const==4 then --神圣类反伤处理技能
                  damageTable.damage=damageTable.damage*(1+hero.pure_return*hero:GetStrength()/100)
                end
             end
	        else
	           if hero and hero.sp~=nil and  damageTable.damagetype_const==2 then --无明确来源技能
	             damageTable.damage=damageTable.damage*(1+hero.sp*hero:GetIntellect()/100) 
	           end
	        end
          
          if victim and victim:HasModifier("modifier_faceless_undie") then  --如果有不死的技能
              if damageTable.damage>=victim:GetHealth() then  --无法将血量扣除小于1
                 return false
              end
          end

          if victim and victim:HasModifier("modifier_invulnerable_immune") then  --如果有无敌免疫的的buff
              if hero:IsInvulnerable() then  --无敌期间无法对其做成伤害
                 return false
              end
          end

          if victim and victim:HasModifier("modifier_refraction_affect") then  --如果有折光，移除一层此伤害不起作用
              local refractionAbility=victim:FindAbilityByName("ta_refraction_datadriven")
              RemoveModifierOneStack(victim,"modifier_refraction_affect",refractionAbility) 
              return false
          end
          
          if victim and victim:HasModifier("modifier_tinker_boss_invulnerable") then  --如果有TK Boss的活性护甲
              if damageTable.entindex_inflictor_const and EntIndexToHScript(damageTable.entindex_inflictor_const)  and EntIndexToHScript(damageTable.entindex_inflictor_const).GetAbilityName and EntIndexToHScript(damageTable.entindex_inflictor_const):GetAbilityName()=="creature_techies_suicide"  then  --只有炸弹人自爆能造成伤害
              else
                return false
              end
          end

        	if self._currentRound and playerid and playerid~=-1  then
        		self._currentRound._vPlayerStats[playerid].nTotalDamage=self._currentRound._vPlayerStats[playerid].nTotalDamage+damageTable.damage
        	end
         
          if damageTable.entindex_inflictor_const~=nil and  EntIndexToHScript(damageTable.entindex_inflictor_const)  and  EntIndexToHScript(damageTable.entindex_inflictor_const).GetAbilityName  and  (EntIndexToHScript(damageTable.entindex_inflictor_const):GetAbilityName()=="spectre_dispersion_datadriven" or EntIndexToHScript(damageTable.entindex_inflictor_const):GetAbilityName()=="item_blade_mail" ) then  --不能反射反伤类的技能        
          else
            if victim and victim:HasModifier("modifier_affixes_spike") then  --处理尖刺技能
                 local damage_table = {}
                 damage_table.attacker = victim
                 damage_table.victim = attacker
                 damage_table.damage_type = DAMAGE_TYPE_PURE
                 damage_table.ability = victim:FindAbilityByName("affixes_ability_spike")
                 damage_table.damage = damageTable.damage
                 damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
                 ApplyDamage(damage_table)
            end
            if victim and victim:HasModifier("modifier_nxy_spike") then  --处理小强的尖刺
                 local damage_table = {}
                 damage_table.attacker = victim
                 damage_table.victim = attacker
                 damage_table.damage_type = DAMAGE_TYPE_PURE
                 damage_table.ability = victim:FindAbilityByName("nyx_boss_spike")
                 damage_table.damage = damageTable.damage*0.6   --反弹60%伤害
                 damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
                 ApplyDamage(damage_table)
            end    
          end

          if victim and victim:HasModifier("modifier_share_damage_passive") then  --处理伤害共享技能
              local allies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
              for _,ally in pairs(allies) do  --共享伤害 不再伤害本体 
                  if ally:HasAbility("share_damage_passive") and ally~=victim  then             
                    local damage_table = {}
                    damage_table.attacker = victim
                    damage_table.victim = ally
                    damage_table.damage_type = DAMAGE_TYPE_PURE
                    damage_table.ability = victim:FindAbilityByName("share_damage_passive")
                    damage_table.damage = damageTable.damage
                    damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
                    ApplyDamage(damage_table)
                  end
              end 
          end
    end
    if attacker:GetTeam()==DOTA_TEAM_BADGUYS then

        --处理窒息气泡 原始伤害
        if victim:HasModifier("modifier_suffocating_bubble")  then   
            --DeepPrint( damageTable )   
            if damageTable.entindex_inflictor_const ~=nil then --有明确技能伤害来源
              local ability=EntIndexToHScript(damageTable.entindex_inflictor_const) --如果技能为潮汐的两个伤害技能
              --print(ability:GetAbilityName())
              --print(victim.suffocating_bubble_take.."victim.suffocating_bubble_take")
              if (ability:GetAbilityName()=="boss_current_storm" or ability:GetAbilityName()=="boss_greate_gush") and victim.suffocating_bubble_take~=nil and victim.suffocating_bubble_take >0 then
                  --print(ability:GetAbilityName())
                  victim.suffocating_bubble_take=victim.suffocating_bubble_take-damageTable.damage 
                  if victim.suffocating_bubble_take <100 then
                     victim:RemoveModifierByName("modifier_suffocating_bubble")
                     victim.suffocating_bubble_take=nil                    
                  end
                  return false
              end
            end
        end

      	if attacker:HasModifier("modifier_night_damage_stack") then
      		local ability=attacker:FindAbilityByName("night_creature_increase_damage")
      		local magic_enhance_per_stack=ability:GetSpecialValueFor("magic_enhance_per_stack")
      		local stacks_number=attacker:GetModifierStackCount("modifier_night_damage_stack",ability)
      		if damageTable.damagetype_const==2 or damageTable.damagetype_const==4  then
      			damageTable.damage=damageTable.damage* (1+stacks_number*magic_enhance_per_stack)
      		end     	
      	end
        -- 受伤害龙心进入CD
        if victim:HasItemInInventory("item_heart") or victim:HasItemInInventory("item_heart_2")  then
            for i=0,8 do
              local itemAbility=victim:GetItemInSlot(i)
              if itemAbility~=nil then
                  if itemAbility:GetAbilityName()=="item_heart" or itemAbility:GetAbilityName()=="item_heart_2" then
                     local heartCooldown=itemAbility:GetCooldown(1)
                     itemAbility:StartCooldown(heartCooldown)
                  end
              end
            end
        end

         if victim and victim:HasModifier("modifier_mage_shield_1_active") then  --如果有法术护盾
            if damageTable.damage>=victim:GetHealth() then  --无法将血量扣除小于1
               local overDamage=damageTable.damage-victim:GetHealth() --过量伤害
               victim:ReduceMana(overDamage/2)
               if victim:GetMana()<1 then
                  victim:RemoveModifierByName("modifier_mage_shield_1_active")
                  return true
               else
                  return false
               end
            end
         end

         if victim and victim:HasModifier("modifier_mage_shield_2_active") then  --如果有法术护盾
            if damageTable.damage>=victim:GetHealth() then  --无法将血量扣除小于1
               local overDamage=damageTable.damage-victim:GetHealth() --过量伤害
               victim:ReduceMana(overDamage/3)
               if victim:GetMana()<1 then
                  victim:RemoveModifierByName("modifier_mage_shield_2_active")
                  return true
               else
                  return false
               end
            end
         end

         if victim and victim:HasModifier("modifier_mage_shield_3_active") then  --如果有法术护盾
            if damageTable.damage>=victim:GetHealth() then  --无法将血量扣除小于1
               local overDamage=damageTable.damage-victim:GetHealth() --过量伤害
               victim:ReduceMana(overDamage/4)
               if victim:GetMana()<1 then
                  victim:RemoveModifierByName("modifier_mage_shield_3_active")
                  return true
               else
                  return false
               end
            end
         end
        
         if victim and victim:HasModifier("modifier_mage_shield_4_active") then  --如果有法术护盾
            if damageTable.damage>=victim:GetHealth() then  --无法将血量扣除小于1
               local overDamage=damageTable.damage-victim:GetHealth() --过量伤害
               victim:ReduceMana(overDamage/4)
               if victim:GetMana()<1 then
                  victim:RemoveModifierByName("modifier_mage_shield_4_active")
                  return true
               else
                  return false
               end
            end
         end

         local gameMode = GameRules:GetGameModeEntity().CHoldoutGameMode
         local round = gameMode._currentRound  
         --监听部分过关奖励

         if round and round.achievement_flag==true and damageTable.entindex_inflictor_const ~=nil then        
            
            local ability=EntIndexToHScript(damageTable.entindex_inflictor_const) --找到伤害来源的技能
            --血魔关 血之祭祀
            if ability and ability.GetAbilityName and  round._alias=="bloodseeker" and ability:GetAbilityName()=="bloodseeker_blood_bath_holdout"  then
                if victim and victim:IsRealHero() then
                   Notifications:BottomToAll({hero = victim:GetUnitName(), duration = 4})
                   Notifications:BottomToAll({text = "#round4_acheivement_fail_note", duration = 4, style = {color = "Orange"}, continue = true})                       
                   QuestSystem:RefreshAchQuest("Achievement",0,1)
                   round.achievement_flag=false
                end
            end
            --萨特关 尖刺
            if ability and ability.GetAbilityName and round._alias=="satyr" and ability:GetAbilityName()=="creature_aoe_spikes"  then
                if victim and victim:IsRealHero() then
                   Notifications:BottomToAll({hero = victim:GetUnitName(), duration = 4})
                   Notifications:BottomToAll({text = "#round5_acheivement_fail_note", duration = 4, style = {color = "Orange"}, continue = true})                       
                   QuestSystem:RefreshAchQuest("Achievement",0,1)
                   round.achievement_flag=false
                end
            end
         end
     end
   end

   return true
end




function CHoldoutGameMode:OrderFilter(orderTable)
  
  --PrintTable(orderTable)

  local caster = EntIndexToHScript(orderTable.units["0"])    --order_type 14 为捡东西指令 

  if caster and caster:GetUnitName()=="npc_dota_courier" and caster.synPlayerId then  --如果信使为某人专属
     if caster.synPlayerId~=orderTable.issuer_player_id_const then  --非专属玩家操作信使
       return false
     end
  end

  if caster and caster:GetUnitName()=="npc_dota_courier" then --如果是信使

      if orderTable.order_type==14 then  --有人控制信使捡东西
         caster.nControlledPickPlayerId = orderTable.issuer_player_id_const  --记录下谁用信使捡东西
      end
      
      if orderTable.order_type==5 and orderTable.entindex_ability then  --有人使用信使抓钩
          local ability=EntIndexToHScript(orderTable.entindex_ability)
          if ability.GetAbilityName  and  ability:GetAbilityName()=="courier_hook_datadriven"  then
             caster.nControlledPickPlayerId = orderTable.issuer_player_id_const  --记录下谁用信使抓钩
          end
      end

      if  not (orderTable.entindex_ability  and orderTable.entindex_ability > 1) then --如果有人控制信使施法以外的操作
         if caster.bSellInterrupted==nil then 
            caster.bSellInterrupted=true 
         end
      end

  end


  if orderTable.entindex_ability ~=0 and orderTable.entindex_ability ~=-1  and  orderTable.order_type~=11 and caster.GetIntellect  then  --order_type=11 为技能升级指令
      local ability=EntIndexToHScript(orderTable.entindex_ability)
      if  ability and   ability.GetAbilityName   and  ability:GetAbilityName()~="storm_spirit_ball_lightning"  and  ability:GetAbilityName()~="ogre_magi_unrefined_fireblast"   and  ability.IsInAbilityPhase  and  caster.manaCostIns~=nil  and  not ability:IsInAbilityPhase()  and  not ability:IsChanneling()   then  -- 有法强
          local current_mana=caster:GetMana()
          local mana_cost=ability:GetManaCost(-1) --获取技能耗蓝
          --print("caster.manaCostIns"..caster.manaCostIns)
          caster:ReduceMana(mana_cost*(caster.manaCostIns*caster:GetIntellect()/100))
          if caster:GetMana()< mana_cost then  --如果扣完蓝不够了
              Timers:CreateTimer({
                      endTime = 0.0001,  --再把蓝退回回去
                        callback = function()
                        caster:SetMana(current_mana)
                      end})
          end
      end
      if  ability and   ability.GetAbilityName   and  ability:GetAbilityName()=="arc_warden_tempest_double"  then  -- 风暴双雄
          local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
          for _,unit in pairs(units) do
              print(unit:GetUnitName())
              print(unit:IsTempestDouble())
              if unit:IsTempestDouble() and unit:GetPlayerOwnerID()==caster:GetPlayerOwnerID()  then --移除控制者的风暴双雄
                  unit:ForceKill(true)  --移除掉原来的双雄
              end
          end          
      end

      --球状闪电 不允许向地图外施法
      if ability and   ability.GetAbilityName  and ability:GetAbilityName()=="storm_spirit_ball_lightning" then
          if orderTable.position_x>4900 or orderTable.position_y>4700 or orderTable.position_x<-4500 or orderTable.position_y<-4100 then
             return false
          end
      end

  end
  return true
end


function CHoldoutGameMode:ModifierGainedFilter(event)
  
  --PrintTable(event)
  if not event.entindex_parent_const then 
    return true
  end
  
  local target = EntIndexToHScript(event.entindex_parent_const)
  
  if target and target.GetUnitName and target:GetUnitName() then   --不受斩杀
      if target:HasModifier("modifier_faceless_undie") and event.name_const=="modifier_ice_blast" then
        return false
      end
  end
  
  return true

end