function CHoldoutGameMode:OrderFilter(orderTable)
  
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