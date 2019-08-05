modifier_invoker_forge_spirit_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_invoker_forge_spirit_lua:IsHidden()
    return true
end

function modifier_invoker_forge_spirit_lua:IsDebuff()
    return false
end

function modifier_invoker_forge_spirit_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_invoker_forge_spirit_lua:OnCreated(kv)
    self.armor = self:GetAbility():GetSpecialValueFor("spirit_armor") - self:GetParent():GetPhysicalArmorBaseValue()
    self.attack_range = self:GetAbility():GetSpecialValueFor("spirit_attack_range")
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_invoker_forge_spirit_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
        MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
    }

    return funcs
end

function modifier_invoker_forge_spirit_lua:GetModifierAttackRangeBonus()
    return self.attack_range
end

function modifier_invoker_forge_spirit_lua:GetModifierPhysicalArmorBonus()
    return self.armor
end