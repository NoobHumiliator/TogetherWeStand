modifier_explode_expansion_ally_aura_effect = class({})

--------------------------------------------------------------------------------

function modifier_explode_expansion_ally_aura_effect:IsDebuff()
	return false
end


function modifier_explode_expansion_ally_aura_effect:IsHidden()
	return true
end


function modifier_explode_expansion_ally_aura_effect:RemoveOnDeath()
	return false
end