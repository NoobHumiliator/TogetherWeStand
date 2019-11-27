function necrotic_attack_landed(keys)

    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local modifierName = "modifier_necrotic_stack"

    local duration = ability:GetLevelSpecialValueFor("debuff_duration", ability:GetLevel() - 1)

    if target:HasModifier(modifierName) then
        local current_stack = target:GetModifierStackCount(modifierName, ability)
        ability:ApplyDataDrivenModifier(caster, target, modifierName, { Duration = duration })
        target:SetModifierStackCount(modifierName, ability, current_stack + 1)
    else
        ability:ApplyDataDrivenModifier(caster, target, modifierName, { Duration = duration })
        target:SetModifierStackCount(modifierName, ability, 1)
    end

end