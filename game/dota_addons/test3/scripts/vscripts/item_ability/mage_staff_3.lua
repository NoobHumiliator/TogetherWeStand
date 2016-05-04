
function ApplySpValue( keys )
	local caster = keys.caster
	if caster.sp ==nil then
       caster.sp=1.5
       elseif caster.sp<1.4 then
       caster.sp=1.5
     end
end



function RemoveSpValue( keys )
  local caster = keys.caster
	if caster.sp and caster.sp < 1.9 then 
	   if caster:HasModifier("modifier_mage_staff_2_datadriven") then 
	   	  caster.sp=1
	      elseif caster:HasModifier("modifier_mage_staff_1_datadriven") then
            caster.sp=0.5
            else
	        caster.sp=nil   
       end
    end
end
