item_rapier_1_datadriven = class({})
LinkLuaModifier("modifier_item_rapier", "item_ability/item_rapier", LUA_MODIFIER_MOTION_NONE)

function item_rapier_1_datadriven:GetIntrinsicModifierName()
    return "modifier_item_rapier"
end

function item_rapier_1_datadriven:OnOwnerDied()
if not IsServer() or self:GetItemSlot() > 5 then return end
    if self.hadBroken then
        self:GetParent():RemoveItem(self)
    else
        self.hadBroken = true
        self.modifier:SetStackCount(1)
    end
end

item_rapier_2_datadriven = class({})

function item_rapier_2_datadriven:GetIntrinsicModifierName()
    return "modifier_item_rapier"
end

function item_rapier_2_datadriven:OnOwnerDied()
if not IsServer() or self:GetItemSlot() > 5 then return end
    if self.hadBroken then
        self:GetParent():RemoveItem(self)
    else
        self.hadBroken = true
        self.modifier:SetStackCount(1)
    end
end

item_rapier_3_datadriven = class({})

function item_rapier_3_datadriven:GetIntrinsicModifierName()
    return "modifier_item_rapier"
end

function item_rapier_3_datadriven:OnOwnerDied()
if not IsServer() or self:GetItemSlot() > 5 then return end
    if self.hadBroken then
        self:GetParent():RemoveItem(self)
    else
        self.hadBroken = true
        self.modifier:SetStackCount(1)
    end
end

item_rapier_4_datadriven = class({})

function item_rapier_4_datadriven:GetIntrinsicModifierName()
    return "modifier_item_rapier"
end

function item_rapier_4_datadriven:OnOwnerDied()
    if not IsServer() or self:GetItemSlot() > 5 then return end
    if self.hadBroken then
        self:GetParent():RemoveItem(self)
    else
        self.hadBroken = true
        self.modifier:SetStackCount(1)
    end
end

modifier_item_rapier = class({})

function modifier_item_rapier:IsHidden()
    return true
end

function modifier_item_rapier:IsPurgable()
    return false
end

function modifier_item_rapier:IsDebuff()
    return false
end

function modifier_item_rapier:RemoveOnDeath()
    return false
end

function modifier_item_rapier:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_item_rapier:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
    }

    return funcs
end

function modifier_item_rapier:GetModifierPreAttack_BonusDamage()
    if self:GetAbility().hadBroken or not IsServer() and self:GetStackCount() == 1 then
        return self.bonus_damage / 2
    end
    return self.bonus_damage
end

function modifier_item_rapier:OnCreated(kv)
    self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
    self:GetAbility().modifier = self
    if self:GetAbility().hadBroken then
        self:SetStackCount(1)
    end
end

function modifier_item_rapier:OnDestroy()
    if not IsServer() then return end
    self:GetAbility().modifier = nil
end