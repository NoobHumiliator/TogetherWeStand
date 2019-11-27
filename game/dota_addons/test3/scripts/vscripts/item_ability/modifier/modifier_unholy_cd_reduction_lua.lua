modifier_unholy_cd_reduction_lua = class({})

--------------------------------------------------------------------------------
function modifier_unholy_cd_reduction_lua:IsHidden()
    return true
end
-------------------------------------------------------------------------------
function modifier_unholy_cd_reduction_lua:OnCreated(kv)
    local ability = self:GetAbility()
    local stack_modifier = "modifier_unholy_datadriven"
    local cool_down_reduce_per_stack = self:GetAbility():GetSpecialValueFor("cool_down_reduce")
    local incoming_damage_per_stack = self:GetAbility():GetSpecialValueFor("incoming_damage")
    local caster = self:GetCaster()
    self.cool_down_reduce = cool_down_reduce_per_stack * caster:GetModifierStackCount(stack_modifier, ability)
    self.incoming_reduce = incoming_damage_per_stack * caster:GetModifierStackCount(stack_modifier, ability)
end

--------------------------------------------------------------------------------
function modifier_unholy_cd_reduction_lua:OnRefresh(kv)
    local ability = self:GetAbility()
    local stack_modifier = "modifier_unholy_stack_datadriven"
    local cool_down_reduce_per_stack = self:GetAbility():GetSpecialValueFor("cool_down_reduce")
    local incoming_damage_per_stack = self:GetAbility():GetSpecialValueFor("incoming_damage")


    local caster = self:GetCaster()
    local cool_down_reduce = cool_down_reduce_per_stack * caster:GetModifierStackCount(stack_modifier, ability)
    if cool_down_reduce > 75 then
        cool_down_reduce = 75
    end
    self.cool_down_reduce = cool_down_reduce


    local incoming_reduce = incoming_damage_per_stack * caster:GetModifierStackCount(stack_modifier, ability)
    if incoming_reduce < -95 then
        incoming_reduce = -95
    end
    self.incoming_reduce = incoming_reduce


end

--------------------------------------------------------------------------------
function modifier_unholy_cd_reduction_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
    }
    return funcs
end

--------------------------------------------------------------------------------
function modifier_unholy_cd_reduction_lua:GetModifierPercentageCooldown(params)
    return self.cool_down_reduce
end

--------------------------------------------------------------------------------
function modifier_unholy_cd_reduction_lua:GetModifierIncomingDamage_Percentage(params)
    return self.incoming_reduce
end