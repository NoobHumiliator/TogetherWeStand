
function ApplySpValue( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster.sp then
     else
       caster.sp=0.5
    end
end



function RemoveSpValue( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster.sp and caster.sp==0.5 then  --存在法强并且法强为0.5，则把法强清空
	   caster.sp=nil
     else
       --否则啥也不干
    end
end
