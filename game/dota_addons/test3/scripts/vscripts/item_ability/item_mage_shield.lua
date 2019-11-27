item_mage_shield_1 = class({})
LinkLuaModifier("modifier_item_mage_shield", "item_ability/modifier/modifier_item_mage_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mage_shield_buff", "item_ability/modifier/modifier_item_mage_shield_buff", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_mage_shield_1:GetIntrinsicModifierName()
    return "modifier_item_mage_shield"
end

function item_mage_shield_1:OnSpellStart()
    self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_item_mage_shield_buff", { duration = self:GetSpecialValueFor("duration"), texture = "item_mage_shield_1" })
end

--------------------------------------------------------------------------------

item_mage_shield_2 = class({})

--------------------------------------------------------------------------------
function item_mage_shield_2:GetIntrinsicModifierName()
    return "modifier_item_mage_shield"
end

function item_mage_shield_2:OnSpellStart()
    self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_item_mage_shield_buff", { duration = self:GetSpecialValueFor("duration"), texture = "item_mage_shield_1" })
end

--------------------------------------------------------------------------------

item_mage_shield_3 = class({})

--------------------------------------------------------------------------------
function item_mage_shield_3:GetIntrinsicModifierName()
    return "modifier_item_mage_shield"
end

function item_mage_shield_3:OnSpellStart()
    self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_item_mage_shield_buff", { duration = self:GetSpecialValueFor("duration"), texture = "item_mage_shield_1" })
end

--------------------------------------------------------------------------------

item_mage_shield_4 = class({})

--------------------------------------------------------------------------------
function item_mage_shield_4:GetIntrinsicModifierName()
    return "modifier_item_mage_shield"
end

function item_mage_shield_4:OnSpellStart()
    self:GetParent():AddNewModifier(self:GetParent(), self, "modifier_item_mage_shield_buff", { duration = self:GetSpecialValueFor("duration"), texture = "item_mage_shield_1" })
end

--------------------------------------------------------------------------------