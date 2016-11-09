LinkLuaModifier( "modifier_increase_mana_cost_lua","item_ability/modifier_increase_mana_cost_lua", LUA_MODIFIER_MOTION_NONE )
function ApplySpValue( keys )
	local caster = keys.caster
	if caster.sp ==nil then
       caster.sp=1.4
       --caster:AddNewModifier(caster, self, "modifier_increase_mana_cost_lua", nil )
       elseif caster.sp<1.3 then
       caster.sp=1.4
     end
end


function RemoveSpValue( keys )
  local caster = keys.caster
	if caster.sp and caster.sp < 1.5 then 
	   if caster:HasModifier("modifier_mage_staff_2_datadriven") then 
	   	  caster.sp=1
	      elseif caster:HasModifier("modifier_mage_staff_1_datadriven") then
            caster.sp=0.6
            else
	        caster.sp=nil
          --caster:RemoveModifierByName("modifier_increase_mana_cost_lua")   
       end
    end
end
