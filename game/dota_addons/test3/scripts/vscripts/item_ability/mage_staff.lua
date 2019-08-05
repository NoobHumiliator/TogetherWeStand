function ApplySpValue(keys)
    local caster = keys.caster
    local ability = keys.ability
    if caster:HasModifier("modifier_mage_staff_6_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_6_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_5_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_5_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_4_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_4_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_3_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_3_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_2_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_2_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_1_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_1_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    else
        caster.sp = nil
        --caster.manaCostIns = nil
    end
    if caster.sp ~= nil then
        print(caster:GetUnitName() .. "'sp: " .. caster.sp)
    else
        print(caster:GetUnitName() .. "'sp: nil")
    end
end

function RemoveSpValue(keys)
    local caster = keys.caster
    if caster:HasModifier("modifier_mage_staff_6_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_6_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_5_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_5_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_4_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_4_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_3_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_3_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_2_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_2_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    elseif caster:HasModifier("modifier_mage_staff_1_datadriven") then
        local ability = caster:FindModifierByName("modifier_mage_staff_1_datadriven"):GetAbility();
        caster.sp = ability:GetSpecialValueFor("spell_power")
        --caster.manaCostIns = ability:GetSpecialValueFor("mana_increase")
    else
        caster.sp = nil
        --caster.manaCostIns = nil
    end
    if caster.sp ~= nil then
        print(caster:GetUnitName() .. "'sp: " .. caster.sp)
    else
        print(caster:GetUnitName() .. "'sp: nil")
    end
end