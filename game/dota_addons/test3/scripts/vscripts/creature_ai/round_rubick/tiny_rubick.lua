function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    thisEntity.hFlop = thisEntity:FindAbilityByName("tiny_rubick_fade_bolt")
    thisEntity.flSearchRadius = 400

    thisEntity:SetContextThink("TinyRubickThink", TinyRubickThink, 0.5)
end

--------------------------------------------------------------------------------
function TinyRubickThink()
    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() then
        return 0.1
    end

    if thisEntity.hFlop:IsFullyCastable() then
        local hEnemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, thisEntity.flSearchRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_CLOSEST, false)
        if #hEnemies > 0 then
            return CastFadeBolt(hEnemies[RandomInt(1, #hEnemies)])
        end
    end
    return AttackNearestEnemy(thisEntity)
end

--------------------------------------------------------------------------------
function CastFadeBolt(enemy)
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
        AbilityIndex = thisEntity.hFlop:entindex(),
        TargetIndex = enemy:entindex()
    })

    return 0.5
end