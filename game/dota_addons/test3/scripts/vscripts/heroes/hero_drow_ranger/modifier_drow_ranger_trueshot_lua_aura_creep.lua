modifier_drow_ranger_trueshot_lua_aura_creep = class({})

--------------------------------------------------------------------------------

function modifier_drow_ranger_trueshot_lua_aura_creep:IsHidden() 
	return true
end

--------------------------------------------------------------------------------
function modifier_drow_ranger_trueshot_lua_aura_creep:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------

function modifier_drow_ranger_trueshot_lua_aura_creep:IsPurgable()
	return false
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura_creep:IsAura()
	return true
end

----------------------------------------
function modifier_drow_ranger_trueshot_lua_aura_creep:GetModifierAura()
	return  "modifier_drow_ranger_trueshot_lua_aura_effect"
end
----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura_creep:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura_creep:GetAuraSearchType()
	return DOTA_UNIT_TARGET_CREEP
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura_creep:GetAuraRadius()
	return -1
end

----------------------------------------