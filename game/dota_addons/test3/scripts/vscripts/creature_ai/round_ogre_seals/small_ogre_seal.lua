function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    thisEntity.hFlop = thisEntity:FindAbilityByName("small_ogreseal_flop")
    thisEntity.flSearchRadius = 400

    thisEntity:SetContextThink("OgreSealThink", OgreSealThink, 0.5)
end

--------------------------------------------------------------------------------
function OgreSealThink()
    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() == true then
        return 0.5
    end

    local hEnemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, thisEntity.flSearchRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
    if #hEnemies == 0 then
        return AttackNearestEnemy(thisEntity)
    end

    if thisEntity.hFlop ~= nil and thisEntity.hFlop:IsFullyCastable() then
        return CastBellyFlop(hEnemies[#hEnemies])
    end

    return 0.5
end

--------------------------------------------------------------------------------
function CastBellyFlop(enemy)
    local vToTarget = enemy:GetOrigin() - thisEntity:GetOrigin()
    vToTarget = vToTarget:Normalized()
    local vTargetPos = thisEntity:GetOrigin() + vToTarget * 50

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        AbilityIndex = thisEntity.hFlop:entindex(),
        Position = vTargetPos,
        Queue = false,
    })

    return 4
end

--------------------------------------------------------------------------------