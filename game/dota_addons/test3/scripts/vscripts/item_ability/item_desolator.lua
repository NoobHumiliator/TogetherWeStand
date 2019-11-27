--[[	Author: d2imba
		Date:	07.01.2015	]]
function DesolatorProjectile(keys)
    local caster = keys.caster
    if caster:IsRangedAttacker() then
        if caster:HasModifier("modifier_item_imba_desolator") or caster:HasModifier("modifier_item_imba_desolator_2") then
            caster:SetRangedProjectileName("particles/items_fx/desolator_projectile.vpcf")
            caster.beforeDesolator = caster:GetRangedProjectileName()
        else
            if caster.beforeDesolator then
                caster:SetRangedProjectileName(caster.beforeDesolator)
            end
        end
    end
end

function GetBaseRangedProjectileName(unit)
    local unit_name = unit:GetUnitName()
    unit_name = string.gsub(unit_name, "dota", "imba")
    local unit_table = unit:IsHero() and GameRules.HeroKV[unit_name] or GameRules.UnitKV[unit_name]
    return unit_table and unit_table["ProjectileModel"] or ""
end


function DesolatorHit_2(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local sound_hit = keys.sound_hit
    local modifier_armor = keys.modifier_armor

    -- If a higher-level desolator is present, do nothing
    if caster:HasModifier("modifier_item_desolator_3_unique") then
        return nil
    end

    if caster:HasModifier("modifier_item_desolator_4_unique") then
        return nil
    end

    -- Parameters
    local base_stacks = ability:GetLevelSpecialValueFor("base_stacks", ability_level)
    local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)

    -- If the target has no armor debuff stacks, apply the base value
    if not target:HasModifier(modifier_armor) then
        AddStacks(ability, caster, target, modifier_armor, base_stacks, true)

        -- Play hit sound
        target:EmitSound(sound_hit)

        -- Else, add one stack, or refresh them if already at the maximum value
    else
        local current_stacks = target:GetModifierStackCount(modifier_armor, nil)
        if current_stacks < max_stacks then
            AddStacks(ability, caster, target, modifier_armor, 1, true)

            -- Play hit sound
            target:EmitSound(sound_hit)
        else
            AddStacks(ability, caster, target, modifier_armor, 0, true)
        end
    end
end



function DesolatorHit_3(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local sound_hit = keys.sound_hit
    local modifier_armor = keys.modifier_armor

    -- If a higher-level desolator is present, do nothing
    if caster:HasModifier("modifier_item_desolator_4_unique") then
        return nil
    end

    -- Parameters
    local base_stacks = ability:GetLevelSpecialValueFor("base_stacks", ability_level)
    local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)

    -- If the target has no armor debuff stacks, apply the base value
    if not target:HasModifier(modifier_armor) then
        AddStacks(ability, caster, target, modifier_armor, base_stacks, true)

        -- Play hit sound
        target:EmitSound(sound_hit)

        -- Else, add one stack, or refresh them if already at the maximum value
    else
        local current_stacks = target:GetModifierStackCount(modifier_armor, nil)
        if current_stacks < max_stacks then
            AddStacks(ability, caster, target, modifier_armor, 1, true)

            -- Play hit sound
            target:EmitSound(sound_hit)
        else
            AddStacks(ability, caster, target, modifier_armor, 0, true)
        end
    end
end



function DesolatorHit_4(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local sound_hit = keys.sound_hit
    local modifier_armor = keys.modifier_armor
    -- 必定触发
    -- Parameters
    local base_stacks = ability:GetLevelSpecialValueFor("base_stacks", ability_level)
    local max_stacks = ability:GetLevelSpecialValueFor("max_stacks", ability_level)

    -- If the target has no armor debuff stacks, apply the base value
    if not target:HasModifier(modifier_armor) then
        AddStacks(ability, caster, target, modifier_armor, base_stacks, true)

        -- Play hit sound
        target:EmitSound(sound_hit)

        -- Else, add one stack, or refresh them if already at the maximum value
    else
        local current_stacks = target:GetModifierStackCount(modifier_armor, nil)
        if current_stacks < max_stacks then
            AddStacks(ability, caster, target, modifier_armor, 1, true)

            -- Play hit sound
            target:EmitSound(sound_hit)
        else
            AddStacks(ability, caster, target, modifier_armor, 0, true)
        end
    end
end



function AddStacks(ability, caster, unit, modifier, stack_amount, refresh)
    if unit:HasModifier(modifier) then
        if refresh then
            ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
        end
        unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, nil) + stack_amount)
    else
        ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
        unit:SetModifierStackCount(modifier, ability, stack_amount)
    end
end