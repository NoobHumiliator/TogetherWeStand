modifier_doom_bringer_devour_lua = class({})
--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_lua:IsPurgable()            return false end
function modifier_doom_bringer_devour_lua:IsDebuff()            return true end
function modifier_doom_bringer_devour_lua:IsHidden()            return false end

--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_lua:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_lua:OnCreated(kv)
    self.regen = self:GetAbility():GetSpecialValueFor("regen")
    self.bonus_gold = self:GetAbility():GetSpecialValueFor("bonus_gold")
    if not IsServer() then return end
	local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_doom_3")
    if talent and talent:GetLevel() ~= 0 then
        self.bonus_gold = self.bonus_gold + talent:GetSpecialValueFor("value")
    end
end
--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_lua:OnRefresh(kv)
    self:OnCreated(kv)
end
--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
    }

    return funcs
end
--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_lua:GetModifierConstantHealthRegen(params)
    return self.regen
end
--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_lua:OnDestroy(params)

    if IsServer() then
        local caster = self:GetAbility():GetCaster()
        if caster and caster:IsAlive() then
            SendOverheadEventMessage(caster, OVERHEAD_ALERT_GOLD, caster, self.bonus_gold, nil)
            self:GetAbility():GetCaster():ModifyGold(self.bonus_gold, true, 0)
        end
    end

end