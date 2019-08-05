item_longclaws_amulet = class({})
LinkLuaModifier("modifier_item_longclaws_amulet", "item_ability/modifier/modifier_item_longclaws_amulet", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_longclaws_amulet:GetIntrinsicModifierName()
    return "modifier_item_longclaws_amulet"
end

--------------------------------------------------------------------------------
function item_longclaws_amulet:Spawn()
    self.required_level = self:GetSpecialValueFor("required_level")
end

--------------------------------------------------------------------------------
function item_longclaws_amulet:OnHeroLevelUp()
    if IsServer() then
        if self:GetCaster():GetLevel() == self.required_level and self:IsInBackpack() == false then
            self:OnUnequip()
            self:OnEquip()
        end
    end
end

--------------------------------------------------------------------------------
function item_longclaws_amulet:IsMuted()
    if self.required_level > self:GetCaster():GetLevel() then
        return true
    end
    if not self:GetCaster():IsHero() then
        return true
    end

    return self.BaseClass.IsMuted(self)
end