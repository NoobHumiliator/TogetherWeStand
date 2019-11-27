modifier_bonus_magical_resistance = class({})

function modifier_bonus_magical_resistance:IsHidden()
    return true
end

function modifier_bonus_magical_resistance:IsPurgable()
    return false
end

function modifier_bonus_magical_resistance:IsPassive()
    return true
end

function modifier_bonus_magical_resistance:IsPermanent()
    return true
end

function modifier_bonus_magical_resistance:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
    }
    return funcs
end

function modifier_bonus_magical_resistance:GetModifierMagicalResistanceBonus()
    return self:GetStackCount()
end