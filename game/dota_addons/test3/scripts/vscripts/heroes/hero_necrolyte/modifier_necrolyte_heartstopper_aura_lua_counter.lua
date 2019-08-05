modifier_necrolyte_heartstopper_aura_lua_counter = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_necrolyte_heartstopper_aura_lua_counter:IsHidden()
    return self:GetStackCount() == 0
end

function modifier_necrolyte_heartstopper_aura_lua_counter:IsDebuff()
    return false
end

function modifier_necrolyte_heartstopper_aura_lua_counter:IsPurgable()
    return false
end

function modifier_necrolyte_heartstopper_aura_lua_counter:RemoveOnDeath()
    return false
end

function modifier_necrolyte_heartstopper_aura_lua_counter:GetTexture()
    return "necrolyte_heartstopper_aura"
end

function modifier_necrolyte_heartstopper_aura_lua_counter:GetModifierConstantHealthRegen()
    return self.health_regen * self:GetStackCount()
end

function modifier_necrolyte_heartstopper_aura_lua_counter:GetModifierConstantManaRegen()
    return self.mana_regen * self:GetStackCount()
end

function modifier_necrolyte_heartstopper_aura_lua_counter:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
    }

    return funcs
end

function modifier_necrolyte_heartstopper_aura_lua_counter:OnCreated(kv)
    self.mana_regen = self:GetAbility():GetSpecialValueFor("mana_regen")
    self.health_regen = self:GetAbility():GetSpecialValueFor("health_regen")
end

function modifier_necrolyte_heartstopper_aura_lua_counter:OnRefresh(kv)
    self:OnCreated()
end