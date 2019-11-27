--[[ units/ai/ai_centaur_dunerunner.lua ]]
--------------------------------------------------------------------------------
function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    thisEntity.hEarthbindAbility = thisEntity:FindAbilityByName("creature_dunerunner_earthbind")

    thisEntity:SetContextThink("CentaurDunerunnerThink", CentaurDunerunnerThink, 0.5)
end

--------------------------------------------------------------------------------
function CentaurDunerunnerThink()
    if not IsServer() then
        return
    end

    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() == true then
        return 0.5
    end

    local hEnemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
    if #hEnemies > 0 then

        if thisEntity.hEarthbindAbility ~= nil and thisEntity.hEarthbindAbility:IsFullyCastable() then
            return CastEarthbind(hEnemies[RandomInt(1, #hEnemies)])
        end
    else
        return AttackNearestEnemy()
    end

    return 0.5
end

--------------------------------------------------------------------------------
function CastEarthbind(hEnemy)
    local vEnemySpeed = hEnemy:GetBaseMoveSpeed()
    local vEnemyForward = hEnemy:GetForwardVector()
    local vPos = nil
    if hEnemy:IsMoving() then
        vPos = hEnemy:GetOrigin() + (vEnemyForward * vEnemySpeed)
    else
        vPos = hEnemy:GetOrigin()
    end

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        Position = vPos,
        AbilityIndex = thisEntity.hEarthbindAbility:entindex(),
        Queue = false,
    })
    return 2
end

--------------------------------------------------------------------------------
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

    local fFuzz = RandomFloat(-0.1, 0.1) -- Adds some timing separation to these magi
    return 0.5 + fFuzz
end