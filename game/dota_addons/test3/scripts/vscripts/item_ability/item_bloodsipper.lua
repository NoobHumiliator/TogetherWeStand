--[[	Author: d2imba
		Date:	15.08.2015	]]
function OrchidCrit(keys)
    local caster = keys.caster
    local target = keys.unit
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local damage = keys.damage
    local modifier_orchid = keys.modifier_orchid

    -- Parameters
    local crit_chance = ability:GetLevelSpecialValueFor("crit_chance", ability_level)
    local crit_damage = ability:GetLevelSpecialValueFor("crit_damage", ability_level)
    local bonus_damage = math.max(damage * (crit_damage - 100) / 100, 0)

    -- If there's no valid target, do nothing
    if target:IsBuilding() or target:IsTower() or target == caster then
        return nil
    end

    -- Roll for crit chance
    if RandomInt(1, 100) <= crit_chance then
        caster:RemoveModifierByName(modifier_orchid)
        ApplyDamage({ attacker = caster, victim = target, ability = ability, damage = bonus_damage, damage_type = DAMAGE_TYPE_PURE })
        SendOverheadEventMessage(nil, OVERHEAD_ALERT_CRITICAL, target, damage + bonus_damage, nil)
        ability:ApplyDataDrivenModifier(caster, caster, modifier_orchid, {})
    end
end