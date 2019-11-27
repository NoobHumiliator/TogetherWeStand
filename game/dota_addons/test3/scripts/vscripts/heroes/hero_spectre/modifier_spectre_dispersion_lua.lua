require("util")
--[[Author: Nightborn
	Date: August 27, 2016
]]
modifier_spectre_dispersion_lua = class({})

function modifier_spectre_dispersion_lua:IsHidden()
    return true
end

function modifier_spectre_dispersion_lua:IsPurgable()
    return false
end

function modifier_spectre_dispersion_lua:OnCreated()
    if not IsServer() then
        return
    end
    self.damage_reflect_pct = self:GetAbility():GetSpecialValueFor("damage_reflection_pct")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_spectre_5")
    if talent and talent:GetLevel() > 0 then
        self.damage_reflect_pct = self.damage_reflect_pct + talent:GetSpecialValueFor("value")
    end
    self.max_radius = self:GetAbility():GetSpecialValueFor("max_radius")
    self.min_radius = self:GetAbility():GetSpecialValueFor("min_radius")
end

function modifier_spectre_dispersion_lua:OnRefresh()
    if not IsServer() then
        return
    end
    self.damage_reflect_pct = self:GetAbility():GetSpecialValueFor("damage_reflection_pct")
    local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_spectre_5")
    if talent and talent:GetLevel() > 0 then
        self.damage_reflect_pct = self.damage_reflect_pct + talent:GetSpecialValueFor("value")
    end
    self.max_radius = self:GetAbility():GetSpecialValueFor("max_radius")
    self.min_radius = self:GetAbility():GetSpecialValueFor("min_radius")
end

function modifier_spectre_dispersion_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_spectre_dispersion_lua:GetModifierIncomingDamage_Percentage(params)
    if self:GetParent():PassivesDisabled() then
        return 0
    end
    return -self.damage_reflect_pct
end

function modifier_spectre_dispersion_lua:OnTakeDamage(params)

    -- PrintTable(params)
    local caster = self:GetParent()
    if caster:PassivesDisabled() then
        return
    end
    local attacker = params.attacker
    local original_damage = params.original_damage

    if attacker == nil or params.unit ~= caster or FlagExist(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then
        return
    end

    -- 我方所造成的伤害减少大半
    if attacker:GetTeamNumber() == caster:GetTeamNumber() then
        original_damage = original_damage / 3
    end

    local units = FindUnitsInRadius(
    caster:GetTeamNumber(),
    caster:GetAbsOrigin(),
    nil,
    self.max_radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER,
    false
    )

    for _, unit in pairs(units) do
        local vCaster = caster:GetAbsOrigin()
        local vUnit = unit:GetAbsOrigin()

        local distance = math.max((vUnit - vCaster):Length2D(), self.min_radius)

        local reflect_damage = original_damage * self.damage_reflect_pct / 100
        reflect_damage = reflect_damage * (1 - (distance - self.min_radius) / (self.max_radius - self.min_radius))

        if reflect_damage > (original_damage * 2 / 3) then
            --particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"
        elseif reflect_damage > (original_damage / 3) then
            --particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_fallback_mid.vpcf"
        else
            --particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_b_fallback_low.vpcf"
        end

        --Create particle
        --[[local particle = ParticleManager:CreateParticle( particle_name, PATTACH_POINT_FOLLOW, caster )
			ParticleManager:SetParticleControl(particle, 0, vCaster)
			ParticleManager:SetParticleControl(particle, 1, vUnit)
			ParticleManager:SetParticleControl(particle, 2, vCaster)
        ]]
        
        ApplyDamage({
            victim = unit,
            attacker = caster,
            ability = self:GetAbility(),
            damage = reflect_damage,
            damage_type = params.damage_type,
            damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION,
        })

    end
end