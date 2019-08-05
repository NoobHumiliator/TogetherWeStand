item_gravel_foot = class({})
LinkLuaModifier("modifier_item_gravel_foot", "item_ability/modifier/modifier_item_gravel_foot", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_gravel_foot:GetIntrinsicModifierName()
    return "modifier_item_gravel_foot"
end

--------------------------------------------------------------------------------
function item_gravel_foot:Spawn()
    self.required_level = self:GetSpecialValueFor("required_level")
end

--------------------------------------------------------------------------------
function item_gravel_foot:OnHeroLevelUp()
    if IsServer() then
        if self:GetCaster():GetLevel() == self.required_level and self:IsInBackpack() == false then
            self:OnUnequip()
            self:OnEquip()
        end
    end
end

--------------------------------------------------------------------------------
function item_gravel_foot:IsMuted()
    if self.required_level > self:GetCaster():GetLevel() then
        return true
    end
    if not self:GetCaster():IsHero() then
        return true
    end
    return self.BaseClass.IsMuted(self)
end