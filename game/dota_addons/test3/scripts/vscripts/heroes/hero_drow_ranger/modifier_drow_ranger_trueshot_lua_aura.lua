modifier_drow_ranger_trueshot_lua_aura = class({})

--------------------------------------------------------------------------------

function modifier_drow_ranger_trueshot_lua_aura:IsHidden() 
	return true
end

--------------------------------------------------------------------------------
function modifier_drow_ranger_trueshot_lua_aura:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------

function modifier_drow_ranger_trueshot_lua_aura:IsPurgable()
	return false
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura:IsAura()
	return true
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura:GetModifierAura()
	return  "modifier_drow_ranger_trueshot_lua_aura_effect"
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura:GetAuraRadius()
	return self.radius
end

----------------------------------------

function modifier_drow_ranger_trueshot_lua_aura:OnCreated( kv )
	self.radius = self:GetAbility():GetSpecialValueFor( "radius" )
end

---------------------------------------------