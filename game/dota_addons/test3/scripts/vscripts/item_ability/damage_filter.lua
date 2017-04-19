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


re_table={} --反伤类技能  折射直接扣生命 单独处理
re_table["tiny_craggy_exterior"]=true
re_table["bristleback_quill_spray"]=true
re_table["bristleback_bristleback"]=true
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
          if attacker:HasModifier("modifier_explode_expansion_thinker_aura_effect")  then   --如果身上有虚空罩子的debuff无法造成伤害
             return
          end
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


        	if self._currentRound and playerid then
        		self._currentRound._vPlayerStats[playerid].nTotalDamage=self._currentRound._vPlayerStats[playerid].nTotalDamage+damageTable.damage
        	end
         
          if damageTable.entindex_inflictor_const~=nil and  EntIndexToHScript(damageTable.entindex_inflictor_const)  and  EntIndexToHScript(damageTable.entindex_inflictor_const).GetAbilityName  and  (EntIndexToHScript(damageTable.entindex_inflictor_const):GetAbilityName()=="spectre_dispersion" or EntIndexToHScript(damageTable.entindex_inflictor_const):GetAbilityName()=="item_blade_mail" ) then  --不能反射反伤类的技能        
          else
            if victim and victim:HasModifier("modifier_affixes_spike") then  --处理尖刺技能
                 local damage_table = {}
                 damage_table.attacker = victim
                 damage_table.victim = attacker
                 damage_table.damage_type = DAMAGE_TYPE_PURE
                 damage_table.ability = victim:FindAbilityByName("affixes_ability_spike")
                 damage_table.damage = damageTable.damage
                 damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
                 ApplyDamage(damage_table)
            end
            if victim and victim:HasModifier("modifier_nxy_spike") then  --处理小强的尖刺
                 local damage_table = {}
                 damage_table.attacker = victim
                 damage_table.victim = attacker
                 damage_table.damage_type = DAMAGE_TYPE_PURE
                 damage_table.ability = victim:FindAbilityByName("nyx_boss_spike")
                 damage_table.damage = damageTable.damage
                 damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
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
            for i=0,5 do
              local itemAbility=victim:GetItemInSlot(i)
              if itemAbility~=nil then
                  if itemAbility:GetAbilityName()=="item_heart" or itemAbility:GetAbilityName()=="item_heart_2" then
                     local heartCooldown=itemAbility:GetCooldown(1)
                     itemAbility:StartCooldown(heartCooldown)
                  end
              end
            end
        end
     end
   end

   return true
end




function CHoldoutGameMode:OrderFilter(orderTable)
  --DeepPrint( orderTable )
  local caster = EntIndexToHScript(orderTable.units["0"])
  if orderTable.entindex_ability ~=0 and orderTable.entindex_ability ~=-1  and  orderTable.order_type~=11 then  --order_type=11 为技能升级指令
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
  end
  return true
end
