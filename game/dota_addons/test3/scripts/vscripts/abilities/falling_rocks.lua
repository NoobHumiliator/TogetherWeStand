function FallingRockDamage(keys)
    local caster = keys.caster
    local target = keys.target
    local ability = keys.ability

    local victims = FindUnitsInRadius(DOTA_TEAM_BADGUYS, target:GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for _, victim in pairs(victims) do
        if victim:GetUnitName() ~= 'npc_falling_rock_dummy' then
            local damage = victim:GetMaxHealth() * 0.25
            local damage_table = {}
            damage_table.attacker = target
            damage_table.victim = victim
            damage_table.damage_type = DAMAGE_TYPE_PURE
            damage_table.ability = ability
            damage_table.damage = damage
            damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
            ApplyDamage(damage_table)
            victim:AddNewModifier(caster, ability, "modifier_stunned", { duration = 0.5 })
        end
    end

    local flTimeCount = 0
    Timers:CreateTimer({
        endTime = 0.25,
        callback = function()
            local victims = FindUnitsInRadius(DOTA_TEAM_BADGUYS, target:GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
            for _, victim in pairs(victims) do
                if victim:GetUnitName() ~= 'npc_falling_rock_dummy' then
                    local damage = victim:GetMaxHealth() * 0.05
                    local damage_table = {}
                    damage_table.attacker = target
                    damage_table.victim = victim
                    damage_table.damage_type = DAMAGE_TYPE_PURE
                    damage_table.ability = ability
                    damage_table.damage = damage
                    damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
                    ApplyDamage(damage_table)
                end
            end
            flTimeCount = flTimeCount + 0.25
            if flTimeCount > 2.4 then
                return nil
            else
                return 0.25
            end
        end
    })

end