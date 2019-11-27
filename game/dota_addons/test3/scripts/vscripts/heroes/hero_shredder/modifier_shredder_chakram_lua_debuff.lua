modifier_shredder_chakram_lua_debuff = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_shredder_chakram_lua_debuff:IsHidden()
    return false
end

function modifier_shredder_chakram_lua_debuff:IsDebuff()
    return true
end

function modifier_shredder_chakram_lua_debuff:IsStunDebuff()
    return false
end

function modifier_shredder_chakram_lua_debuff:IsPurgable()
    return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_shredder_chakram_lua_debuff:OnCreated(kv)
    -- references
    if self:GetAbility() and not self:GetAbility():IsNull() then
        self.slow = self:GetAbility():GetSpecialValueFor("slow")
    else
        -- ability is deleted
        self.slow = 0
    end
    self.step = 5
end

function modifier_shredder_chakram_lua_debuff:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_shredder_chakram_lua_debuff:OnRemoved()
end

function modifier_shredder_chakram_lua_debuff:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_shredder_chakram_lua_debuff:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
    }

    return funcs
end

function modifier_shredder_chakram_lua_debuff:GetModifierMoveSpeedBonus_Percentage()
    -- reduced to step of 5
    return -math.floor((100 - self:GetParent():GetHealthPercent()) / self.step) * self.slow
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_shredder_chakram_lua_debuff:GetStatusEffectName()
    return "particles/status_fx/status_effect_frost.vpcf"
end