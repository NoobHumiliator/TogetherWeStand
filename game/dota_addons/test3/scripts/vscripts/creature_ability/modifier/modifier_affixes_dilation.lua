modifier_affixes_dilation = class({})

-----------------------------------------------------------------------------------------

function modifier_affixes_dilation:IsHidden()
	return false
end

-----------------------------------------------------------------------------------------

function modifier_affixes_dilation:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_affixes_dilation:IsPermanent()
	return true
end
----------------------------------------------------------------------------------------

function modifier_affixes_dilation:IsDebuff()
	return true
end

-----------------------------------------------------------------------------------------

function modifier_affixes_dilation:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_COOLDOWN_REDUCTION_CONSTANT
	}
	return funcs
end
----------------------------------------

function modifier_affixes_dilation:GetModifierCooldownReduction_Constant( params )
	return -80
end

----------------------------------------