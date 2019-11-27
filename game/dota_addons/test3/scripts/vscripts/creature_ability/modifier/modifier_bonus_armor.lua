modifier_bonus_armor = class({})

function modifier_bonus_armor:IsHidden()
    return true
end

function modifier_bonus_armor:IsPurgable()
    return false
end

function modifier_bonus_armor:IsPassive()
    return true
end

function modifier_bonus_armor:IsPermanent()
    return true
end

function modifier_bonus_armor:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }
    return funcs
end

function modifier_bonus_armor:GetModifierPhysicalArmorBonus()
    return self:GetStackCount()
end