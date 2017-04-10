function ApplyReValue( keys )
    local caster = keys.caster
    local ability= keys.ability

    if caster:HasModifier("modifier_item_tank_armor_2") then
      --[[
      caster.pysical_return=ability:GetLevelSpecialValueFor("physical_bonus_damage_per_str", 1)
      caster.magical_return=ability:GetLevelSpecialValueFor("magical_bonus_damage_per_str", 1)
      caster.pure_return=ability:GetLevelSpecialValueFor("pure_bonus_damage_per_str", 1)
      ]]
      caster.pysical_return=1.8
      caster.magical_return=1.5
      caster.pure_return=0.2
    elseif caster:HasModifier("modifier_item_tank_armor_1") then
      --[[
        caster.pysical_return=ability:GetLevelSpecialValueFor("physical_bonus_damage_per_str", 0)
        caster.magical_return=ability:GetLevelSpecialValueFor("magical_bonus_damage_per_str", 0)
        caster.pure_return=ability:GetLevelSpecialValueFor("pure_bonus_damage_per_str", 0)
        ]]
          caster.pysical_return=1.2
          caster.magical_return=1.0
          caster.pure_return=0.13
      else
        caster.pysical_return=nil
        caster.magical_return=nil
        caster.pure_return=nil
    end
    if caster.pysical_return~=nil then
      print(caster:GetUnitName().. "'pysical_return: " ..caster.pysical_return)
      print(caster:GetUnitName().. "'magical_return: " ..caster.magical_return)
      print(caster:GetUnitName().. "'pure_return: " ..caster.pure_return)
    else
      print(caster:GetUnitName().. "'all_return: nil")
    end
end



function RemoveReValue( keys )
    local caster = keys.caster
    if caster:HasModifier("modifier_item_tank_armor_2") then
       caster.pysical_return=1.8
       caster.magical_return=1.5
       caster.pure_return=0.2
    elseif caster:HasModifier("modifier_item_tank_armor_1") then
          caster.pysical_return=1.2
          caster.magical_return=1.0
          caster.pure_return=0.13
       else
         caster.pysical_return=nil
         caster.magical_return=nil
         caster.pure_return=nil
    end            
    if caster.pysical_return~=nil then
      print(caster:GetUnitName().. "'pysical_return: " ..caster.pysical_return)
      print(caster:GetUnitName().. "'magical_return: " ..caster.magical_return)
      print(caster:GetUnitName().. "'pure_return: " ..caster.pure_return)
    else
      print(caster:GetUnitName().. "'all_return: nil")
    end
end

  