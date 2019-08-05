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
    self.damage_reflect_pct = self.damage_reflect_pct * 0.01
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
    self.damage_reflect_pct = self.damage_reflect_pct * 0.01
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
    return -self.damage_reflect_pct
end

function modifier_spectre_dispersion_lua:OnTakeDamage(event)

    local re_table = {
        item_blade_mail = true,
        nyx_assassin_spiked_carapace = true,
        spectre_dispersion = true,
        spectre_dispersion_lua = true,
        creature_spectre_dispersion = true,
        affixes_ability_spike = true,
        creature_nyx_spike = true,
        frostivus2018_spectre_active_dispersion = true,
    }

    -- PrintTable(event)
    local caster = self:GetParent()
    local attacker = event.attacker
    local ability = event.inflictor
    local original_damage = event.original_damage

    -- 限制折射，由我方造成的伤害不会触发
    if event.unit ~= self:GetParent() or attacker:GetTeamNumber() == caster:GetTeamNumber() or ability and re_table[ability:GetAbilityName()] then
        return
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

        local reflect_damage

        local distance = (vUnit - vCaster):Length2D()

        --取消掉全部的效果粒子特效
        --Within 300 radius
        if distance <= self.min_radius then
            reflect_damage = original_damage * self.damage_reflect_pct
            --particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"
            --Between 301 and 475 radius
        elseif distance <= (self.min_radius + 175) then
            reflect_damage = original_damage * (self.damage_reflect_pct * (1 - (distance - 300) * 0.00142857))
            --particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_fallback_mid.vpcf"
            --Same formula as previous statement but different particle
        else
            reflect_damage = original_damage * (self.damage_reflect_pct * (1 - (distance - 300) * 0.00142857))
            --particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion_b_fallback_low.vpcf"
        end

        if caster.pure_return ~= nil then
            reflect_damage = reflect_damage * (1 + caster.pure_return * caster:GetStrength() / 100)
        end

        --particle_name = "particles/units/heroes/hero_spectre/spectre_dispersion.vpcf"
        --Create particle
        --[[				local particle = ParticleManager:CreateParticle( particle_name, PATTACH_POINT_FOLLOW, caster )
				ParticleManager:SetParticleControl(particle, 0, vCaster)
				ParticleManager:SetParticleControl(particle, 1, vUnit)
				ParticleManager:SetParticleControl(particle, 2, vCaster)
				]]
        ApplyDamage({ victim = unit, attacker = caster, ability = self:GetAbility(), damage = reflect_damage, damage_type = event.damage_type })

    end
end