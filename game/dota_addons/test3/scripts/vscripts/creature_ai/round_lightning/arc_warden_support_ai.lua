require("ai_core")

--------------------------------------------------------------------------------
function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    thisEntity.hShieldAbility = thisEntity:FindAbilityByName("arc_warden_magnetic_field")
    thisEntity.hMachineGunAbility = thisEntity:FindAbilityByName("fireball_machine_gun")
    thisEntity.hRayGunAbility = thisEntity:FindAbilityByName("fireball_ray_gun")

    thisEntity:SetContextThink("Arc_Warden_Support_Think", ArcWardenSupportThink, 0.5)
end

--------------------------------------------------------------------------------
function ArcWardenSupportThink()
    if not IsServer() then
        return
    end

    if thisEntity == nil or thisEntity:IsNull() or (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() then
        return 0.1
    end

    if thisEntity.hMachineGunAbility:IsFullyCastable() and not thisEntity:HasModifier("modifier_fireball_ray_gun_thinker") then
        local hEnemies = GetEnemyHeroesInRange(thisEntity, 1400)
        if #hEnemies > 0 then
            local hRandomEnemy = hEnemies[RandomInt(1, #hEnemies)]
            return CastMachineGun(hRandomEnemy)
        end
    end

    if thisEntity.hRayGunAbility:IsFullyCastable() and not thisEntity:HasModifier("modifier_fireball_machine_gun_thinker") then
        local hEnemies = GetEnemyHeroesInRange(thisEntity, 1400)
        if #hEnemies > 0 then
            local hRandomEnemy = hEnemies[RandomInt(1, #hEnemies)]
            return CastRayGun(hRandomEnemy)
        end
    end

    if thisEntity.hShieldAbility:IsFullyCastable() then
        local fRange = thisEntity.hShieldAbility:GetCastRange()
        thisEntity.hTarget = AICore:WeakestAllyHeroInRange(thisEntity, fRange)

        if thisEntity.hTarget and thisEntity.hTarget:GetHealthPercent() < 80 then
            return CastShield(hTarget)
        end

    end

    return AttackNearestEnemy(thisEntity)
end

--------------------------------------------------------------------------------
function CastShield(hTarget)
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        Position = thisEntity.hTarget:GetOrigin(),
        AbilityIndex = thisEntity.hShieldAbility:entindex(),
        Queue = false,                
    })

    return 1
end


function CastMachineGun(hTarget)
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        Position = hTarget:GetOrigin(),
        AbilityIndex = thisEntity.hMachineGunAbility:entindex(),
        Queue = false,
    })

    return 0.5
end


function CastRayGun(hTarget)
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        Position = hTarget:GetOrigin(),
        AbilityIndex = thisEntity.hRayGunAbility:entindex(),
        Queue = false,
    })

    return 0.5
end