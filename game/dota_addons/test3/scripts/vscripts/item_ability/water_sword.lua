LinkLuaModifier( "modifier_water_sword_effect", "item_ability/modifier/modifier_water_sword_effect", LUA_MODIFIER_MOTION_NONE )


function ApplyWaterBuff( keys )
	local caster = keys.caster
	local ability = keys.ability
    if not caster:HasModifier("modifier_water_sword_effect") then
        caster:AddNewModifier(caster,nil,"modifier_water_sword_effect",{})
        caster:SetModifierStackCount("modifier_water_sword_effect", nil, 1)
    else
    	local stack_count = caster:GetModifierStackCount("modifier_water_sword_effect", nil)
    	caster:SetModifierStackCount("modifier_water_sword_effect", nil, stack_count + 1)
    end

end
