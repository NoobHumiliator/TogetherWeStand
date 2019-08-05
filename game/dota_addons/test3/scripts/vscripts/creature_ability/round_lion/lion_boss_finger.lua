function FingerStart(keys)
    -- Ability properties
    local caster = keys.caster
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1


    for i = 1, 135 do  --135个马甲单位
        local x = RandomInt(world_left_x, world_right_x)
        local y = RandomInt(world_left_y, world_right_y)
        local vector = GetGroundPosition(Vector(x, y, 0), nil)
        local entUnit = CreateUnitByName("npc_geodesic_dummy", vector, true, nil, nil, caster:GetTeam())
        --entUnit:AddNewModifier(caster,ability,"modifier_finger_warn",{duration=2.0})
        entUnit:AddNewModifier(caster, ability, "modifier_kill", { duration = 2.5 })
        ability:ApplyDataDrivenModifier(caster, entUnit, "modifier_finger_warn", {})
    end

    EmitGlobalSound("Hero_Lion.FingerOfDeath")
end


function FingerLaunch(keys)

    local caster = keys.caster
    local ability = keys.ability
    local target = keys.target
    --print(target:GetUnitName())
    local finger_projectile =     {
        Target = target,
        Source = caster,
        Ability = ability,
        EffectName = "particles/units/heroes/hero_lion/lion_spell_finger_of_death.vpcf",
        iMoveSpeed = 200,
        bDodgeable = false,
        bVisibleToEnemies = true,
        bReplaceExisting = false,    
    }
    ProjectileManager:CreateTrackingProjectile(finger_projectile)
    Timers:CreateTimer({ endTime = 0.2, callback = function()
        local enemies = FindUnitsInRadius(caster:GetTeamNumber(), target:GetAbsOrigin(), nil, 190, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        for _, enemy in ipairs(enemies) do
            --enemy:EmitSound("Hero_Lion.FingerOfDeathImpact")
            enemy:ForceKill(true)
        end
        return nil
    end })
    target:EmitSound("Hero_Lion.FingerOfDeathImpact")
end