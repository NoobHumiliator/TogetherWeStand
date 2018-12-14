modifier_mage_shield_passive = class({})

--------------------------------------------------------------------------------

function modifier_mage_shield_passive:IsHidden() 
	return true
end

--------------------------------------------------------------------------------

function modifier_mage_shield_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_mage_shield_passive:OnCreated( kv )
	self.bonus_str = self:GetAbility():GetSpecialValueFor( "bonus_str" )
	self.bonus_agi = self:GetAbility():GetSpecialValueFor( "bonus_agi" )
    self.bonus_int = self:GetAbility():GetSpecialValueFor( "bonus_int" )
    self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor( "bonus_mana_regen" )
end

--------------------------------------------------------------------------------

function modifier_mage_shield_passive:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
		MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
		MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_mage_shield_passive:GetModifierBonusStats_Intellect( params )
	return self.bonus_int
end 
--------------------------------------------------------------------------------

function modifier_mage_shield_passive:GetModifierBonusStats_Strength( params )
	return self.bonus_str
end 
--------------------------------------------------------------------------------

function modifier_mage_shield_passive:GetModifierBonusStats_Agility( params )
	return self.bonus_agi
end 
--------------------------------------------------------------------------------

function modifier_mage_shield_passive:GetModifierConstantManaRegen( params )
	return self.bonus_mana_regen
end 

--------------------------------------------------------------------------------

