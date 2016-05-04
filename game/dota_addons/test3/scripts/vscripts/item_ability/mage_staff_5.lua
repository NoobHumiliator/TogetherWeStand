

function ApplySpValue( keys )
	local caster = keys.caster
	if caster.sp ==nil then
       caster.sp=2.5
       elseif caster.sp<2.4 then
       caster.sp=2.5
     end
end



function RemoveSpValue( keys )
  local caster = keys.caster
	if caster.sp and caster.sp < 2.9 then 
    if caster:HasModifier("modifier_mage_staff_4_datadriven") then
      caster.sp=2.0
	    elseif caster:HasModifier("modifier_mage_staff_3_datadriven") then
         caster.sp=1.5
	      elseif caster:HasModifier("modifier_mage_staff_2_datadriven") then 
	   	    caster.sp=1
	       elseif caster:HasModifier("modifier_mage_staff_1_datadriven") then
            caster.sp=0.5
            else
	         caster.sp=nil   
       end
    end
end
