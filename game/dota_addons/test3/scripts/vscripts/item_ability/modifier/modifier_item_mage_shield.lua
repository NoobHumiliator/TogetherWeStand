modifier_item_mage_shield = class({})

function modifier_item_mage_shield:IsHidden()
    return true
end

function modifier_item_mage_shield:IsDebuff()
    return false
end

function modifier_item_mage_shield:IsPurgable()
    return false
end

function modifier_item_mage_shield:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_mage_shield:GetModifierBonusStats_Strength()
    return self.bonus_str
end

function modifier_item_mage_shield:GetModifierBonusStats_Agility()
    return self.bonus_agi
end

function modifier_item_mage_shield:GetModifierBonusStats_Intellect()
    return self.bonus_int
end

function modifier_item_mage_shield:GetModifierConstantHealthRegen()
    return self.bonus_health_regen
end

function modifier_item_mage_shield:GetModifierConstantManaRegen()
    return self.bonus_mana_regen
end

function modifier_item_mage_shield:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_STRENGTH_BONUS,
        MODIFIER_PROPERTY_STATS_AGILITY_BONUS,
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }
    return funcs
end

function modifier_item_mage_shield:OnCreated(kv)
    self.bonus_str = self:GetAbility():GetSpecialValueFor("bonus_str")
    self.bonus_agi = self:GetAbility():GetSpecialValueFor("bonus_agi")
    self.bonus_int = self:GetAbility():GetSpecialValueFor("bonus_int")
    self.bonus_health_regen = self:GetAbility():GetSpecialValueFor("bonus_health_regen")
    self.bonus_mana_regen = self:GetAbility():GetSpecialValueFor("bonus_mana_regen")
end

function modifier_item_mage_shield:OnDestroy()
end