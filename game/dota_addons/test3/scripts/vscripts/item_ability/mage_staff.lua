LinkLuaModifier( "modifier_increase_mana_cost_lua","item_ability/modifier_increase_mana_cost_lua", LUA_MODIFIER_MOTION_NONE )

function ApplySpValue( keys )
    local caster = keys.caster
    if caster:HasModifier("modifier_mage_staff_6_datadriven") then
      caster.sp=2.0
    elseif caster:HasModifier("modifier_mage_staff_5_datadriven") then
      caster.sp=1.8
      elseif caster:HasModifier("modifier_mage_staff_4_datadriven") then
        caster.sp=1.6
        elseif caster:HasModifier("modifier_mage_staff_3_datadriven") then
           caster.sp=1.3
           elseif caster:HasModifier("modifier_mage_staff_2_datadriven") then 
             caster.sp=1.0
             elseif caster:HasModifier("modifier_mage_staff_1_datadriven") then
               caster.sp=0.6
              else
               caster.sp=nil   
    end
    if caster.sp~=nil then
      print(caster:GetUnitName().. "'sp: " ..caster.sp)
    else
      print(caster:GetUnitName().. "'sp: nil")
    end
end



function RemoveSpValue( keys )
    local caster = keys.caster
    if caster:HasModifier("modifier_mage_staff_6_datadriven") then
      caster.sp=2.0
    elseif caster:HasModifier("modifier_mage_staff_5_datadriven") then
      caster.sp=1.8
      elseif caster:HasModifier("modifier_mage_staff_4_datadriven") then
        caster.sp=1.6
        elseif caster:HasModifier("modifier_mage_staff_3_datadriven") then
           caster.sp=1.3
           elseif caster:HasModifier("modifier_mage_staff_2_datadriven") then 
       	     caster.sp=1.0
             elseif caster:HasModifier("modifier_mage_staff_1_datadriven") then
               caster.sp=0.6
              else
               caster.sp=nil   
    end
    if caster.sp~=nil then
      print(caster:GetUnitName().. "'sp: " ..caster.sp)
    else
      print(caster:GetUnitName().. "'sp: nil")
    end
end
