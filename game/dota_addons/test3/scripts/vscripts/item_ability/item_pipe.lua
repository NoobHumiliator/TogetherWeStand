FirstLevelAuraMap = {
      vengefulspirit_command_aura = "vengefulspirit_command_aura_level_2",
      beastmaster_inner_beast = "beastmaster_inner_beast_level_2",
      omniknight_degen_aura="omniknight_degen_aura_level_2",
      spirit_breaker_empowering_haste="spirit_breaker_empowering_haste_level_2",
      elder_titan_natural_order="elder_titan_natural_order_level_2",
      abyssal_underlord_atrophy_aura="abyssal_underlord_atrophy_aura_level_2",
      nevermore_dark_lord="nevermore_dark_lord_level_2",
      skeleton_king_vampiric_aura="skeleton_king_vampiric_aura_level_2",
      crystal_maiden_brilliance_aura="crystal_maiden_brilliance_aura_level_2",
      luna_lunar_blessing="luna_lunar_blessing_level_2",
      drow_ranger_trueshot="drow_ranger_trueshot_level_2",
      lycan_feral_impulse="lycan_feral_impulse_level_2",
      rubick_null_field="rubick_null_field_level_2",
      necrolyte_heartstopper_aura_datadriven="necrolyte_heartstopper_aura_datadriven_level_2",
      lich_frost_aura="lich_frost_aura_level_2"
   }

SecondLevelAuraMap = {
      vengefulspirit_command_aura_level_2 = "vengefulspirit_command_aura_level_3",
      beastmaster_inner_beast_level_2 = "beastmaster_inner_beast_level_3",
      omniknight_degen_aura_level_2="omniknight_degen_aura_level_3",
      spirit_breaker_empowering_haste_level_2="spirit_breaker_empowering_haste_level_3",
      elder_titan_natural_order_level_2="elder_titan_natural_order_level_3",
      abyssal_underlord_atrophy_aura_level_2="abyssal_underlord_atrophy_aura_level_3",
      nevermore_dark_lord_level_2="nevermore_dark_lord_level_3",
      skeleton_king_vampiric_aura_level_2="skeleton_king_vampiric_aura_level_3",
      crystal_maiden_brilliance_aura_level_2="crystal_maiden_brilliance_aura_level_3",
      luna_lunar_blessing_level_2="luna_lunar_blessing_level_3",
      drow_ranger_trueshot_level_2="drow_ranger_trueshot_level_3",
      lycan_feral_impulse_level_2="lycan_feral_impulse_level_3",
      rubick_null_field_level_2="rubick_null_field_level_3",
      necrolyte_heartstopper_aura_datadriven_level_3="necrolyte_heartstopper_aura_datadriven_level_3",
      lich_frost_aura_level_2="lich_frost_aura_level_3"

   }



function EquipPipe(keys)
  local  caster = keys.caster
  local  level = keys.level
  
  if level==1 then   --将初始技能替换为二级
       
      for k,v in pairs(FirstLevelAuraMap) do
          if caster:HasAbility(k) then
             local ability=caster:FindAbilityByName(k)
             local index=ability:GetAbilityIndex()
             local level=ability:GetLevel()
             caster:RemoveAbility(k)
             print("v"..v)
             local newAbility=caster:AddAbility(v)

             newAbility:SetAbilityIndex(index)
             newAbility:SetLevel(level)
          end
      end
  end

  if level==2 then   --将二级技能替换成三级
       
      for k,v in pairs(FirstLevelAuraMap) do
          if caster:HasAbility(k) then
             local ability=caster:FindAbilityByName(k)
             local index=ability:GetAbilityIndex()
             local level=ability:GetLevel()

             caster:RemoveAbility(k)
             local newAbility=caster:AddAbility(v)
             newAbility:SetAbilityIndex(index)
             newAbility:SetLevel(level)
          end
      end


      for k,v in pairs(SecondLevelAuraMap) do
          if caster:HasAbility(k) then
             local ability=caster:FindAbilityByName(k)
             local index=ability:GetAbilityIndex()
             local level=ability:GetLevel()

             caster:RemoveAbility(k)
             local newAbility=caster:AddAbility(v)
             newAbility:SetAbilityIndex(index)
             newAbility:SetLevel(level)
          end
      end

  end


end