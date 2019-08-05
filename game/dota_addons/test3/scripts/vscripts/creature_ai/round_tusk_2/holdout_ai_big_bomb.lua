require("ai_shared")
require("event_queue")

function Spawn(entityKeyValues)
    if thisEntity == nil then
        return
    end

    if IsServer() == false then
        return
    end

    thisEntity.EventQueue = CEventQueue()

    thisEntity.hExplode = thisEntity:FindAbilityByName("creature_big_bomb_explode")
    local fInitialDelay = RandomFloat(0, 1.5) -- separating out the timing of all the ranged creeps' thinks
    thisEntity:SetContextThink("BigBombThink", BigBombThink, fInitialDelay)
end

function BigBombThink()

    if thisEntity.hExplode and thisEntity.hExplode:IsFullyCastable() then
        local hEnemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
        if #hEnemies > 0 then
            CastExplode(thisEntity)
        end
    end

    return AttackNearestEnemy(thisEntity)
end

function CastExplode(hCaster)
    --printf("DIE DIE DIE!")
    local hAbility = hCaster.hExplode
    ExecuteOrderFromTable({
        UnitIndex = hCaster:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        Position = vPosition,
        AbilityIndex = hAbility:entindex(),
        Queue = false,
    })
    return 0.5
end