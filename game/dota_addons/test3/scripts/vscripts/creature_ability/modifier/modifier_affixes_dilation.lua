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

function modifier_affixes_dilation:GetTexture()
	return "dilation"
end


-----------------------------------------------------------------------------------------

function modifier_affixes_dilation:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_ABILITY_FULLY_CAST
	}
	return funcs
end
----------------------------------------

function modifier_affixes_dilation:OnAbilityFullyCast( params )
	if not IsServer() then return end
	local casted_ability= params.ability
	casted_ability:StartCooldown( casted_ability:GetCooldownTimeRemaining()*3)
end

----------------------------------------