modifier_boss_ancient_apparition_ice_thorn = class({})

------------------------------------------------------------------
function modifier_boss_ancient_apparition_ice_thorn:GetTexture()
	return "crystal_maiden_frostbite"
end
------------------------------------------------------------------

function modifier_boss_ancient_apparition_ice_thorn:OnCreated( kv )
end

function modifier_boss_ancient_apparition_ice_thorn:GetStatusEffectName()  
	return "particles/status_fx/status_effect_wyvern_cold_embrace.vpcf"
end

--------------------------------------------------------------------------------

function modifier_boss_ancient_apparition_ice_thorn:CheckState()
	local state = {}
	state[MODIFIER_STATE_STUNNED] = true
	state[MODIFIER_STATE_FROZEN] = true
	
	return state
end




