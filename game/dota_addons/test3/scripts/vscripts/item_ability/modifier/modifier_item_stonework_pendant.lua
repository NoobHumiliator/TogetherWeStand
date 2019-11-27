modifier_item_stonework_pendant = class({})

------------------------------------------------------------------------------
function modifier_item_stonework_pendant:IsHidden()
    return true
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:IsPurgable()
    return false
end

----------------------------------------
function modifier_item_stonework_pendant:OnCreated(kv)
    self.health_multiple = self:GetAbility():GetSpecialValueFor("health_multiple")
    self.flBonusHP = self:GetParent():GetMaxMana()
    self.flBonusHPRegen = self:GetParent():GetManaRegen()
    self:StartIntervalThink(0.5)
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:OnIntervalThink()
    self.flBonusHP = self.flBonusHP + self:GetParent():GetMaxMana()
    self.flBonusHPRegen = self.flBonusHPRegen + self:GetParent():GetManaRegen()
    if IsServer() then
        self:GetParent():CalculateStatBonus()
    end
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_PROPERTY_SPELLS_REQUIRE_HP,
    }
    return funcs
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierHealthBonus(params)
    return self.flBonusHP
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierConstantHealthRegen(params)
    return self.flBonusHPRegen
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierManaBonus(params)
    return -self.flBonusHP
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierConstantManaRegen(params)
    return -self.flBonusHPRegen
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierSpellsRequireHP(params)
    return self.health_multiple
end