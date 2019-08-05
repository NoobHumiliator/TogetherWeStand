function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    IceAgeAbility = thisEntity:FindAbilityByName("boss_ancient_apparition_ice_age")
    ThornAbility = thisEntity:FindAbilityByName("boss_ancient_apparition_ice_thorn")
    BeamAbility = thisEntity:FindAbilityByName("boss_ancient_apparition_beam")

    thisEntity:SetContextThink("AncientApparitionBossThink", AncientApparitionBossThink, 1)
end

function AncientApparitionBossThink()
    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() == true then
        return 1
    end

    -- 引导激光
    if thisEntity:IsChanneling() == true then
        return 0.5
    end

    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 1500, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)

    if #enemies > 0 and BeamAbility ~= nil and BeamAbility:IsFullyCastable() then
        return Beam(enemies[1])
    end


    if ThornAbility:IsFullyCastable() then
        return Thorn()
    end

    --至少有一个尖刺
    if IceAgeAbility:IsFullyCastable() and thisEntity.vThornThinkers and #thisEntity.vThornThinkers > 0 then
        return IceAge()
    end

    return AttackNearestEnemy()
end


function IceAge()
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = IceAgeAbility:entindex(),
        Queue = false,
    })
    return 2.5
end

function Thorn()

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = ThornAbility:entindex(),
        Queue = false,
    })

    return 1.5
end


function Beam(enemy)
    if enemy == nil then
        return
    end

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        AbilityIndex = BeamAbility:entindex(),
        Position = enemy:GetOrigin(),
        Queue = false,
    })

    return 5
end



function AttackNearestEnemy()  --攻击最近的目标

    local target = nil
    local allEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    if #allEnemies > 0 then
        target = allEnemies[1]
    end

    if target ~= nil and not thisEntity:IsAttacking() then  --避免打断攻击动作

        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = target:GetOrigin()
        })

    end

    return 0.5
end
--------------------------------------------------------------------------------