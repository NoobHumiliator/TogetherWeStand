function ApplyReValue(keys)
    local caster = keys.caster
    if caster:HasModifier("modifier_item_tank_armor_2") then
        local ability = caster:FindModifierByName("modifier_item_tank_armor_2"):GetAbility();
        caster.pysical_return = ability:GetSpecialValueFor("physical_bonus_damage_per_str")
        caster.magical_return = ability:GetSpecialValueFor("magical_bonus_damage_per_str")
        caster.pure_return = ability:GetSpecialValueFor("pure_bonus_damage_per_str")
    elseif caster:HasModifier("modifier_item_tank_armor_1") then
        local ability = caster:FindModifierByName("modifier_item_tank_armor_1"):GetAbility();
        caster.pysical_return = ability:GetSpecialValueFor("physical_bonus_damage_per_str")
        caster.magical_return = ability:GetSpecialValueFor("magical_bonus_damage_per_str")
        caster.pure_return = ability:GetSpecialValueFor("pure_bonus_damage_per_str")
    else
        caster.pysical_return = nil
        caster.magical_return = nil
        caster.pure_return = nil
    end
    if caster.pysical_return ~= nil then
        print(caster:GetUnitName() .. "'pysical_return: " .. caster.pysical_return)
        print(caster:GetUnitName() .. "'magical_return: " .. caster.magical_return)
        print(caster:GetUnitName() .. "'pure_return: " .. caster.pure_return)
    else
        print(caster:GetUnitName() .. "'all_return: nil")
    end
end



function RemoveReValue(keys)
    local caster = keys.caster
    local ability = keys.ability
    if caster:HasModifier("modifier_item_tank_armor_2") then
        local ability = caster:FindModifierByName("modifier_item_tank_armor_2"):GetAbility();
        caster.pysical_return = ability:GetSpecialValueFor("physical_bonus_damage_per_str")
        caster.magical_return = ability:GetSpecialValueFor("magical_bonus_damage_per_str")
        caster.pure_return = ability:GetSpecialValueFor("pure_bonus_damage_per_str")
    elseif caster:HasModifier("modifier_item_tank_armor_1") then
        local ability = caster:FindModifierByName("modifier_item_tank_armor_1"):GetAbility();
        caster.pysical_return = ability:GetSpecialValueFor("physical_bonus_damage_per_str")
        caster.magical_return = ability:GetSpecialValueFor("magical_bonus_damage_per_str")
        caster.pure_return = ability:GetSpecialValueFor("pure_bonus_damage_per_str")
    else
        caster.pysical_return = nil
        caster.magical_return = nil
        caster.pure_return = nil
    end
    if caster.pysical_return ~= nil then
        print(caster:GetUnitName() .. "'pysical_return: " .. caster.pysical_return)
        print(caster:GetUnitName() .. "'magical_return: " .. caster.magical_return)
        print(caster:GetUnitName() .. "'pure_return: " .. caster.pure_return)
    else
        print(caster:GetUnitName() .. "'all_return: nil")
    end
end