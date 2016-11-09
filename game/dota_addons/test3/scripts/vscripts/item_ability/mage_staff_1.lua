LinkLuaModifier( "modifier_increase_mana_cost_lua","item_ability/modifier_increase_mana_cost_lua", LUA_MODIFIER_MOTION_NONE )

function ApplySpValue( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster.sp then
     else
       caster.sp=0.6
       --caster:AddNewModifier(caster,self,"modifier_increase_mana_cost_lua",nil)
    end
end



function RemoveSpValue( keys )
	local caster = keys.caster
	local ability = keys.ability
	if caster.sp and caster.sp==0.6 then  --存在法强并且法强为0.5，则把法强清空
	   caster.sp=nil
	   --caster:RemoveModifierByName("modifier_increase_mana_cost_lua")
     else
       --否则啥也不干
    end
end
