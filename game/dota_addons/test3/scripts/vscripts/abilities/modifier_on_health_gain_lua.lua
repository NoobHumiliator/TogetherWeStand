require("util")
modifier_on_health_gain_lua = class({})




function modifier_on_health_gain_lua:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_HEALTH_GAINED,
  MODIFIER_EVENT_ON_HEAL_RECEIVED
}
  return funcs
end


function modifier_on_health_gain_lua:IsHidden()
  return true
end


hp_exempt_table={} --治疗类排除表 这些技能不受治疗增幅
hp_exempt_table["item_datadriven"]=true  --大吸血面具
hp_exempt_table["item_octarine_core"]=true --玲珑心
hp_exempt_table["special_bonus_spell_lifesteal_20"]=true --女王吸血
hp_exempt_table["special_bonus_spell_lifesteal_70"]=true --TK吸血
hp_exempt_table["broodmother_insatiable_hunger"]=true  --蜘蛛吸血
hp_exempt_table["item_satanic"]=true  --撒旦
hp_exempt_table["item_mask_of_madness"]=true  --疯狂面具
hp_exempt_table["item_vladmir"]=true  --祭品
hp_exempt_table["life_stealer_feast"]=true  --盛宴
hp_exempt_table["skeleton_king_vampiric_aura"]=true  --吸血光环
hp_exempt_table["abaddon_borrowed_time"]=true  --回光返照


function modifier_on_health_gain_lua:OnHealReceived( keys ) 

    if IsServer()  and keys.unit == self:GetParent() then

      local parent = self:GetParent()
      local unit=keys.unit
      local gain=keys.gain
      local ability=self:GetAbility()
      local overflow=gain+parent:GetHealth()-parent:GetMaxHealth()
      if overflow<0 then
       overflow=0
      end
      local effective=gain-overflow --有效治疗量

      if unit:HasModifier( "modifier_necrotic_stack" ) then  --先处理死疽
          local necrotic_stack = unit:GetModifierStackCount( "modifier_necrotic_stack", nil)
          if necrotic_stack>100 then
            necrotic_stack=100
          end 

          local damage= effective* (necrotic_stack * 0.01)   --有效治疗乘以死疽层数
          local old_hp = unit:GetHealth()
          local new_hp = old_hp - damage
          effective=effective-damage --有效治疗量扣除死疽伤害

          if unit:IsAlive() then
            if new_hp < 1.000000 then
              unit:Kill(ability, unit)
            else
              unit:SetHealth(new_hp)
            end
          end     
      end


      if keys.inflictor then  --处理治疗增益
             local healer
             if keys.inflictor.GetCaster then
             healer=keys.inflictor:GetCaster()
             elseif  keys.inflictor.GetUnitName then
               healer=keys.inflictor
             end

             local healerMultiple=0
             if healer:HasModifier("modifier_item_healer_3") then
                healerMultiple =1.8
              else
                if healer:HasModifier("modifier_item_healer_2") then
                  healerMultiple =1.2
                else
                  if healer:HasModifier("modifier_item_healer_1") then
                    healerMultiple=0.4
                  end
                end
             end
             if healerMultiple>0  and not hp_exempt_table[keys.inflictor:GetClassname()] then   --防止二次死疽，直接修改生命值
                local bonus_heal=math.ceil(effective*healerMultiple*healer:GetIntellect()/100)
                local current_health=unit:GetHealth()
                local max_health=unit:GetMaxHealth()
                if (current_health+bonus_heal)>max_health then
                  bonus_heal=max_health-current_health
                  unit:SetHealth(unit:GetMaxHealth())
                else
                  local set_health=current_health+bonus_heal
                  unit:SetHealth(set_health)
                end
                effective=effective+bonus_heal
                 --[[
                 print("inflictor class"..keys.inflictor:GetClassname())
                 print(keys.inflictor:GetClassname())
                 print("healer"..healer:GetUnitName())
                 print("receiver"..unit:GetUnitName())
                 print("total gain: "..gain)
                 print("overflow: "..overflow)
                 print("effective: "..(gain-overflow) )
                 print("bonus_heal: "..bonus_heal )
                 print("-------------------------------------------------------------")
                 ]]
             end
            --统计治疗量
            local playerid=nil
            if healer:GetOwner() then
              playerid=healer:GetOwner():GetPlayerID()
            end
            if playerid==nil then
             print("healer"..healer:GetUnitName().."has no playerid")
            end
            local game_mode=GameRules:GetGameModeEntity().CHoldoutGameMode
            if game_mode._currentRound and playerid then
             game_mode._currentRound._vPlayerStats[playerid].nTotalHeal=game_mode._currentRound._vPlayerStats[playerid].nTotalHeal+effective
            end
            --统计结束

       end
       

      if unit:HasModifier("modifier_overflow_show") and overflow>0 then  --处理溢出
           if unit.heal_absorb==nil then
             unit.heal_absorb=gain
           else
             unit.heal_absorb=unit.heal_absorb+gain
             local stack=math.floor(unit.heal_absorb/100)
             ability:ApplyDataDrivenModifier( unit, unit, "modifier_overflow_stack", {} )
             unit:SetModifierStackCount( "modifier_overflow_stack", ability, stack )
           end
      end

      if unit.heal_absorb~=nil then  --处理溢出的吸收量
         local damage=math.min(unit.heal_absorb, effective)
         unit.heal_absorb=unit.heal_absorb-damage
         local damage_table = {}
          damage_table.attacker = self:GetCaster()
          damage_table.victim = unit
          damage_table.damage_type = DAMAGE_TYPE_PURE
          damage_table.ability = self:GetAbility()
          damage_table.damage = damage
          damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
          if unit:GetHealth()/unit:GetMaxHealth()<0.99 then
             ApplyDamage(damage_table)  --满血不造成伤害
          end
         if unit.heal_absorb<=0 then
            unit:RemoveModifierByName("modifier_overflow_stack")
            unit.heal_absorb=nil
         else
            local stack=math.floor(unit.heal_absorb/100)
            ability:ApplyDataDrivenModifier( unit, unit, "modifier_overflow_stack", {} )
            unit:SetModifierStackCount( "modifier_overflow_stack", ability, stack )
         end
      end 

    end --IsServer
end