LinkLuaModifier( "modifier_increase_mana_cost_lua","item_ability/modifier_increase_mana_cost_lua", LUA_MODIFIER_MOTION_NONE )

function ApplySpValue( keys )
	local caster = keys.caster
	if caster.sp ==nil then
       caster.sp=2.3
       --caster:AddNewModifier(caster, self, "modifier_increase_mana_cost_lua", nil )
       elseif caster.sp<2.2 then
       caster.sp=2.3
     end
end



function RemoveSpValue( keys )
  local caster = keys.caster
	if caster.sp and caster.sp < 2.4 then 
    if caster:HasModifier("modifier_mage_staff_5_datadriven") then
     caster.sp=2.0
     elseif caster:HasModifier("modifier_mage_staff_4_datadriven") then
      caster.sp=1.7
	    elseif caster:HasModifier("modifier_mage_staff_3_datadriven") then
         caster.sp=1.4
	      elseif caster:HasModifier("modifier_mage_staff_2_datadriven") then 
	   	    caster.sp=1.0
	       elseif caster:HasModifier("modifier_mage_staff_1_datadriven") then
            caster.sp=0.6
            else
	          caster.sp=nil   
          --caster:RemoveModifierByName("modifier_increase_mana_cost_lua")
       end
    end
end
