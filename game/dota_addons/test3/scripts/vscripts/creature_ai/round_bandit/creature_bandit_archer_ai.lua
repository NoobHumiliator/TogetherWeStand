--------------------------------------------------------------------------------
function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    thisEntity.hArrowAbility = thisEntity:FindAbilityByName("creature_bandit_archer_arrow")

    thisEntity:SetContextThink("BanditArcherThink", BanditArcherThink, 0.5)
end

--------------------------------------------------------------------------------
function BanditArcherThink()
    if not IsServer() then
        return
    end

    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() then
        return 0.5
    end

    local hEnemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    if #hEnemies > 0 then
        for _, hEnemy in pairs(hEnemies) do
            if hEnemy:IsAlive() then
                local flDist = (hEnemy:GetOrigin() - thisEntity:GetOrigin()):Length2D()
                if flDist < 400 and (thisEntity.fTimeOfLastRetreat == nil or (GameRules:GetGameTime() >= thisEntity.fTimeOfLastRetreat + 3)) then
                    return Retreat(hEnemy)
                else
                    if thisEntity.hArrowAbility ~= nil and thisEntity.hArrowAbility:IsFullyCastable() then
                        return CastArrow(hEnemy)
                    end
                    return 0.5
                end
            end
        end
    end

    hEnemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    if #hEnemies > 0 then
        return Approach(hEnemies[1])
    end
    return 0.5
end

--------------------------------------------------------------------------------
function CastArrow(hEnemy)
    --print( "ai_bandit_archer - CastArrow" )
    local fDist = (hEnemy:GetOrigin() - thisEntity:GetOrigin()):Length2D()
    local vTargetPos = hEnemy:GetOrigin()

    if (fDist > 400) and hEnemy and hEnemy:IsMoving() then
        local vLeadingOffset = hEnemy:GetForwardVector() * RandomInt(200, 400)
        vTargetPos = hEnemy:GetOrigin() + vLeadingOffset
    end

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        Position = vTargetPos,
        AbilityIndex = thisEntity.hArrowAbility:entindex(),
        Queue = false,
    })

    return 2
end

--------------------------------------------------------------------------------
function Approach(unit)

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = unit:GetOrigin()
    })

    return 1
end

--------------------------------------------------------------------------------
function Retreat(unit)
    --print( "ai_bandit_archer - Retreat" )
    local vAwayFromEnemy = thisEntity:GetOrigin() - unit:GetOrigin()
    vAwayFromEnemy = vAwayFromEnemy:Normalized()
    local vMoveToPos = thisEntity:GetOrigin() + vAwayFromEnemy * thisEntity:GetIdealSpeed()

    -- if away from enemy is an unpathable area, find a new direction to run to
    local nAttempts = 0
    while ((not GridNav:CanFindPath(thisEntity:GetOrigin(), vMoveToPos)) and (nAttempts < 5)) do
        vMoveToPos = thisEntity:GetOrigin() + RandomVector(thisEntity:GetIdealSpeed())
        nAttempts = nAttempts + 1
    end

    thisEntity.fTimeOfLastRetreat = GameRules:GetGameTime()

    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = vMoveToPos,
    })

    return 1.25
end

--------------------------------------------------------------------------------