--禁止全部伤害

modifier_disable_damage_lua = class({})


function modifier_disable_damage_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end


function modifier_disable_damage_lua:IsHidden()
	return true
end



function modifier_disable_damage_lua:GetModifierTotalDamageOutgoing_Percentage()

	return  -100

end
