LinkLuaModifier("modifier_unholy_cd_reduction_lua", "item_ability/modifier/modifier_unholy_cd_reduction_lua", LUA_MODIFIER_MOTION_NONE)

function Unholy(event)
    local caster = event.caster
    local ability = event.ability
    local center = caster:GetAbsOrigin()
    local radius = ability:GetLevelSpecialValueFor("teammate_range", (ability:GetLevel() - 1))
    local rate = ability:GetLevelSpecialValueFor("damage_percent", (ability:GetLevel() - 1))
    local friend_unit_number = 0
    local friends = {}

    friends = FindUnitsInRadius(caster:GetTeam(), center, nil, radius,
    DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NONE,
    FIND_ANY_ORDER, false)
    for _, unit in pairs(friends) do
        if unit:IsRealHero() and unit ~= caster then
            local particleName = "particles/units/heroes/hero_bane/bane_sap.vpcf"
            local particle = ParticleManager:CreateParticle(particleName, PATTACH_POINT_FOLLOW, caster)

            ParticleManager:SetParticleControlEnt(particle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)

            local damage = unit:GetMaxHealth() * rate * 0.01
            local mana = unit:GetMaxMana() * rate * 0.01

            local damageTable = { victim = unit,
            attacker = caster,
            damage_type = DAMAGE_TYPE_PURE,
            damage_flags = DOTA_DAMAGE_FLAG_HPLOSS,
            damage = damage }
            ApplyDamage(damageTable)
            if not unit:IsNull() and unit:IsAlive() then
                unit:SpendMana(mana, ability)
            end
            friend_unit_number = friend_unit_number + 1
        end
    end

    if friend_unit_number > 0 then
        for i = 1, friend_unit_number do
            ability:ApplyDataDrivenModifier(caster, caster, "modifier_unholy_datadriven", ability)
        end
    end

end



function ApplyUnholy(keys)
    local caster = keys.caster
    local ability = keys.ability
    local stack_modifier = keys.stack_modifier
    local stack_count = caster:GetModifierStackCount(stack_modifier, ability)
    local duration = ability:GetLevelSpecialValueFor("buff_duration", (ability:GetLevel() - 1))

    ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {})

    caster:SetModifierStackCount(stack_modifier, ability, stack_count + 1)
    caster:AddNewModifier(caster, ability, "modifier_unholy_cd_reduction_lua", { duration = duration })
end


function RemoveUnholy(keys)
    local caster = keys.caster
    local ability = keys.ability
    local stack_modifier = keys.stack_modifier
    local stack_count = caster:GetModifierStackCount(stack_modifier, ability)

    if stack_count <= 1 then
        caster:RemoveModifierByName(stack_modifier)
        caster:RemoveModifierByName("modifier_unholy_cd_reduction_lua")
    else
        caster:SetModifierStackCount(stack_modifier, ability, stack_count - 1)
    end
end