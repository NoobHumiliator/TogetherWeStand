modifier_lina_fiery_soul_lua = class({})
LinkLuaModifier("modifier_special_bonus_unique_lina_2", "heroes/hero_lina/modifier_lina_fiery_soul_lua", LUA_MODIFIER_MOTION_NONE)

modifier_special_bonus_unique_lina_2 = class({})

function modifier_special_bonus_unique_lina_2:IsHidden()
    return true
end

function modifier_special_bonus_unique_lina_2:IsPurgable()
    return false
end

function modifier_special_bonus_unique_lina_2:RemoveOnDeath()
    return false
end

--------------------------------------------------------------------------------
-- Classifications
function modifier_lina_fiery_soul_lua:IsHidden()
    return self:GetStackCount() == 0
end

function modifier_lina_fiery_soul_lua:IsDebuff()
    return false
end

function modifier_lina_fiery_soul_lua:IsPurgable()
    return false
end

function modifier_lina_fiery_soul_lua:DestroyOnExpire()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_lina_fiery_soul_lua:OnCreated(kv)
    self.as_bonus = 0
    self.ms_bonus = 0
end

function modifier_lina_fiery_soul_lua:OnRefresh(kv)
    self.as_bonus = self:GetAbility():GetSpecialValueFor("fiery_soul_attack_speed_bonus")
    self.ms_bonus = self:GetAbility():GetSpecialValueFor("fiery_soul_move_speed_bonus")
    self.max_stacks = self:GetAbility():GetSpecialValueFor("fiery_soul_max_stacks")
    self.duration = self:GetAbility():GetSpecialValueFor("fiery_soul_stack_duration")
    if IsServer() then
        local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_lina_2")
        if talent and talent:GetLevel() > 0 then
            self.as_bonus = self.as_bonus + talent:GetSpecialValueFor("value")
            self.ms_bonus = self.ms_bonus + talent:GetSpecialValueFor("value2")
        end
        self:PlayEffects()
    else
        if self:GetCaster():HasModifier("modifier_special_bonus_unique_lina_2") then
            self.as_bonus = self.as_bonus + FindTalentValue("special_bonus_unique_lina_2", "value")
            self.ms_bonus = self.ms_bonus + FindTalentValue("special_bonus_unique_lina_2", "value2")
        end
    end
end

function modifier_lina_fiery_soul_lua:OnRemoved()
end

function modifier_lina_fiery_soul_lua:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_lina_fiery_soul_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
        MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
		MODIFIER_EVENT_ON_ABILITY_EXECUTED
    }

    return funcs
end

function modifier_lina_fiery_soul_lua:GetModifierMoveSpeedBonus_Percentage(params)
    return self:GetStackCount() * self.ms_bonus
end

function modifier_lina_fiery_soul_lua:GetModifierAttackSpeedBonus_Constant(params)
    return self:GetStackCount() * self.as_bonus
end

function modifier_lina_fiery_soul_lua:OnAbilityExecuted(params)
    if not IsServer() then return end
    -- filter
    if params.unit ~= self:GetParent() then return end
    if self:GetParent():PassivesDisabled() then return end
    if not params.ability then return end
    if params.ability:IsItem() or params.ability:IsToggle() then return end

    -- increment stack
    if self:GetStackCount() < self.max_stacks then
        self:IncrementStackCount()
    end

    -- refresh duration
    self:SetDuration(self.duration, true)
    self:StartIntervalThink(self.duration)

    -- Change Effects
    ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self:GetStackCount(), 0, 0))
end
--------------------------------------------------------------------------------
-- Interval Effects
function modifier_lina_fiery_soul_lua:OnIntervalThink()
    -- Expire
    self:StartIntervalThink(-1)
    self:SetStackCount(0)
    ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self:GetStackCount(), 0, 0))
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_lina_fiery_soul_lua:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_lina/lina_fiery_soul.vpcf"

    -- Create Particle
    self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self:GetStackCount(), 0, 0))

    -- buff particle
    self:AddParticle(
    self.effect_cast,
    false, -- bDestroyImmediately
    false, -- bStatusEffect
    -1, -- iPriority
    false, -- bHeroEffect
    false -- bOverheadEffect
    )
end