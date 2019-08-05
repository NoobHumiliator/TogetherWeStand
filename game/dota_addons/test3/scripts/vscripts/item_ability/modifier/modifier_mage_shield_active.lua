function OnTakeDamage(event)

    local caster = event.caster
    local caster = event.abili

    if event.unit == caster then

        local damage = event.damage

        --来自队友的伤害不能被抵抗
        if damage >= caster:GetHealth() then --如果造成过量伤害
            local overDamage = damage - caster:GetHealth()
            caster:ReduceMana(overDamage / event.damage_per_mana)
            if caster:GetMana() < 5 then
                caster:RemoveModifierByName("modifier_mage_shield_active")
            end
        end
    end
end