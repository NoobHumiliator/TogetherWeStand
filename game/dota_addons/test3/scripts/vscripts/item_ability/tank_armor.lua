function ApplyReValue( keys )
    local caster = keys.caster
    local ability= keys.ability
    if caster:HasModifier("modifier_item_tank_armor_2") then
      caster.re=0.7
    elseif caster:HasModifier("modifier_item_tank_armor_1") then
      caster.re=1.0
      else
        caster.re=nil
    end
    if caster.re~=nil then
      print(caster:GetUnitName().. "'re: " ..caster.re)
    else
      print(caster:GetUnitName().. "'re: nil")
    end
end



function RemoveReValue( keys )
    local caster = keys.caster
    if caster:HasModifier("modifier_item_tank_armor_2") then
       caster.re=0.7
    elseif caster:HasModifier("modifier_item_tank_armor_1") then
       caster.re=1.0
       else
         caster.re=nil
    end            
    if caster.re~=nil then
      print(caster:GetUnitName().. "'re: " ..caster.re)
    else
      print(caster:GetUnitName().. "'re: nil")
    end
end
