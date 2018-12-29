 --damageTable.damagetype_const
--1 physical
--2 magical
--4 pure

sp_exempt_table = {}
sp_exempt_table["necrolyte_reapers_scythe_datadriven"]=true
sp_exempt_table["huskar_life_break"]=true
sp_exempt_table["frostivus2018_huskar_life_break"]=true
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

-- DamageFilter不应滥用  只处理两种问题 1 是否造成伤害 2 伤害来源是具体哪个技能 其余问题都不应该从这里处理
function CHoldoutGameMode:DamageFilter(damageTable)
  
   --DeepPrint( damageTable )
   if damageTable and damageTable.entindex_attacker_const then
	  local attacker = EntIndexToHScript(damageTable.entindex_attacker_const)
	  local victim = EntIndexToHScript(damageTable.entindex_victim_const)

    --玩家方造成伤害
	  if  attacker and attacker:GetTeam()==DOTA_TEAM_GOODGUYS then

          --处理法术增幅
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
          -- 统计伤害
        	if self._currentRound and playerid and playerid~=-1  then
        		self._currentRound._vPlayerStats[playerid].nTotalDamage=self._currentRound._vPlayerStats[playerid].nTotalDamage+damageTable.damage
        	end
    end

    if attacker:GetTeam()==DOTA_TEAM_BADGUYS then

        --处理窒息气泡 原始伤害
        if victim:HasModifier("modifier_suffocating_bubble")  then    
            if damageTable.entindex_inflictor_const ~=nil then --有明确技能伤害来源
              local ability=EntIndexToHScript(damageTable.entindex_inflictor_const) --如果技能为潮汐的两个伤害技能
              if (ability:GetAbilityName()=="boss_current_storm" or ability:GetAbilityName()=="boss_greate_gush") and victim.suffocating_bubble_take~=nil and victim.suffocating_bubble_take >0 then
                  victim.suffocating_bubble_take=victim.suffocating_bubble_take-damageTable.damage 
                  if victim.suffocating_bubble_take <100 then
                     victim:RemoveModifierByName("modifier_suffocating_bubble")
                     victim.suffocating_bubble_take=nil                    
                  end
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
