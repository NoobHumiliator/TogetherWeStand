modifier_attribute_bonus_lua = class({})
--------------------------------------------------------------------------------

function modifier_attribute_bonus_lua:IsHidden()
	return true
end
--------------------------------------------------------------------------------

function modifier_attribute_bonus_lua:AllowIllusionDuplicate()
	return true
end

--------------------------------------------------------------------------------

function modifier_attribute_bonus_lua:OnCreated( kv )
	self.bonus_attribute = self:GetAbility():GetSpecialValueFor( "bonus_attribute" )
end

--------------------------------------------------------------------------------

function modifier_attribute_bonus_lua:OnRefresh( kv )
	self.bonus_attribute = self:GetAbility():GetSpecialValueFor( "bonus_attribute" )
end

--------------------------------------------------------------------------------

function modifier_attribute_bonus_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_attribute_bonus_lua:GetModifierBonusStats_Strength( params )
	return self.bonus_attribute* self:GetAbility():GetLevel()
end


function modifier_attribute_bonus_lua:GetModifierBonusStats_Agility( params )
	return self.bonus_attribute* self:GetAbility():GetLevel()
end


function modifier_attribute_bonus_lua:GetModifierBonusStats_Intellect( params )
	return self.bonus_attribute* self:GetAbility():GetLevel()
end
