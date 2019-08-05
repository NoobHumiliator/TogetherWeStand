modifier_hardened_shield_lua = class({})

LinkLuaModifier("modifier_hardened_shield", "item_ability/modifier/modifier_hardened_shield_lua", LUA_MODIFIER_MOTION_NONE)

function modifier_hardened_shield_lua:IsPassive()
    return true
end

function modifier_hardened_shield_lua:IsHidden()
    return false
end

function modifier_hardened_shield_lua:OnCreated()
    self.maximum_health_pct = 0.05--self:GetAbility():GetLevelSpecialValueFor("maximum_health_pct")
end

function modifier_hardened_shield_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_hardened_shield_lua:OnTakeDamage(params)

    if event.unit == self:GetParent() then

        local caster = self:GetParent()
        if params.damage > caster:GetMaxHealth() * self.maximum_health_pct then
            params.damage = caster:GetMaxHealth() * self.maximum_health_pct
        end
    end
end