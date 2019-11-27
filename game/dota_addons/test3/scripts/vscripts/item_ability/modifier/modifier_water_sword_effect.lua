modifier_water_sword_effect = class({})

function modifier_water_sword_effect:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
        MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
    }

    return funcs
end

function modifier_water_sword_effect:OnCreated(kv)
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self.bonus_hp = self:GetAbility():GetSpecialValueFor("bonus_hp")
end

--------------------------------------------------------------------------------
function modifier_water_sword_effect:GetModifierBaseAttack_BonusDamage(params)
    return self:GetStackCount() * self.bonus_damage
end

--------------------------------------------------------------------------------
function modifier_water_sword_effect:GetModifierExtraHealthBonus(params)
    return self:GetStackCount() * self.bonus_hp
end

--------------------------------------------------------------------------------
function modifier_water_sword_effect:GetTexture()
    return "item_water_sword"
end

function modifier_water_sword_effect:IsPermanent()
    return true
end