modifier_item_stonework_pendant = class({})

------------------------------------------------------------------------------
function modifier_item_stonework_pendant:IsHidden()
    return true
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:IsPurgable()
    return false
end

----------------------------------------
function modifier_item_stonework_pendant:OnCreated(kv)
    self.spell_lifesteal = self:GetAbility():GetSpecialValueFor("spell_lifesteal")
    self.flBonusHP = self:GetParent():GetMaxMana()
    self.flBonusHPRegen = self:GetParent():GetManaRegen()
    self:StartIntervalThink(0.5)
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:OnIntervalThink()
    self.flBonusHP = self.flBonusHP + self:GetParent():GetMaxMana()
    self.flBonusHPRegen = self.flBonusHPRegen + self:GetParent():GetManaRegen()
    if IsServer() then
        self:GetParent():CalculateStatBonus()
    end
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_HEALTH_BONUS,
        MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
        MODIFIER_PROPERTY_MANA_BONUS,
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_SPELLS_REQUIRE_HP,
    }
    return funcs
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierHealthBonus(params)
    return self.flBonusHP
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierConstantHealthRegen(params)
    return self.flBonusHPRegen
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierManaBonus(params)
    return -self.flBonusHP
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierConstantManaRegen(params)
    return -self.flBonusHPRegen
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:OnTakeDamage(params)
    if IsServer() then
        local Attacker = params.attacker
        local Target = params.unit
        local Ability = params.inflictor
        local flDamage = params.damage

        if Attacker ~= self:GetParent() or Ability == nil or Target == nil then
            return 0
        end

        if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) == DOTA_DAMAGE_FLAG_REFLECTION then
            return 0
        end
        if bit.band(params.damage_flags, DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL) == DOTA_DAMAGE_FLAG_NO_SPELL_LIFESTEAL then
            return 0
        end

        local nFXIndex = ParticleManager:CreateParticle("particles/items3_fx/octarine_core_lifesteal.vpcf", PATTACH_ABSORIGIN_FOLLOW, Attacker)
        ParticleManager:ReleaseParticleIndex(nFXIndex)

        local flLifesteal = flDamage * self.spell_lifesteal / 100
        Attacker:Heal(flLifesteal, self:GetAbility())
    end
    return 0
end

--------------------------------------------------------------------------------
function modifier_item_stonework_pendant:GetModifierSpellsRequireHP(params)
    return 2
end