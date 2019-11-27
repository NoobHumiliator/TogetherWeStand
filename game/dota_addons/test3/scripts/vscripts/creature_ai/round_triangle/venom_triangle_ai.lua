function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    thisEntity.allies = {}

    venomHealAbility = thisEntity:FindAbilityByName("creature_venom_channel_heal")
    novaAbility = thisEntity:FindAbilityByName("creature_venom_poison_nova")
    thisEntity:SetContextThink("VenomTriangleThink", VenomTriangleThink, 0.25)
    thisEntity:SetContextThink("VenomIncreaseDamage", VenomIncreaseDamage, 3)

end


function VenomIncreaseDamage()

    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() == true then
        return 0.25
    end

    --增加伤害
    if thisEntity.damageMultiple then
        thisEntity.damageMultiple = thisEntity.damageMultiple * 1.1
    end

    return 5

end


--------------------------------------------------------------------------------------------------------
function VenomTriangleThink()
    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() == true then
        return 0.25
    end

    -- 找到其它 BOSS
    local friends = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_CLOSEST, false)
    local bosses = {}
    for _, friend in pairs(friends) do
        if friend:IsAlive() and friend ~= thisEntity and string.match(friend:GetUnitName(), "npc_dota_creature_venom_") then
            table.insert(bosses, friend)
        end
    end

    if #thisEntity.allies ~= #bosses then
        thisEntity.allies = bosses
        if thisEntity.link_to and not thisEntity.link_to:IsAlive() then
            thisEntity.link_to = nil
            ParticleManager:DestroyParticle(thisEntity.linkParticle, false)
            thisEntity.linkParticle = nil
        end
        if thisEntity.link_from and not thisEntity.link_from:IsAlive() then
            thisEntity.link_from = nil
        end
    end

    if thisEntity.link_to == nil then
        for _, ally in pairs(thisEntity.allies) do
            if ally.link_to ~= thisEntity and ally.link_from == nil and ally:GetUnitName() ~= thisEntity:GetUnitName() then
                ally.link_from = thisEntity
                thisEntity.link_to = ally
                local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
                thisEntity.linkParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, thisEntity)
                ParticleManager:SetParticleControlEnt(thisEntity.linkParticle, 1, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
            end
        end
    end



    local killFlag = true


    for _, ally in pairs(thisEntity.allies) do
        --如果有人有技能 却没在读条，取消自杀动作
        local allyHealAbility = ally:FindAbilityByName("creature_venom_channel_heal")
        if not allyHealAbility:IsChanneling() then
            killFlag = false
        end
    end


    if killFlag then
        thisEntity:ForceKill(false)
        return -1
    end

    if venomHealAbility:IsChanneling() then
        return 0.25
    end

    if thisEntity:GetHealth() < thisEntity:GetMaxHealth() * 0.05 then
        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
            AbilityIndex = venomHealAbility:entindex()
        })
    end

    local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
    if #enemies > 0 and novaAbility:IsFullyCastable() then
        CastPoisonNova()
    end

    return AttackNearestEnemy()

end
-----------------------------------------------------------------------------------------------------
function AttackNearestEnemy()  --攻击最近的目标

    local target = nil
    local allEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_CLOSEST, false)
    if #allEnemies > 0 then
        target = allEnemies[1]
    end

    if target ~= nil and not thisEntity:IsAttacking() then  --避免打断攻击动作

        ExecuteOrderFromTable({
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
        })

    end

    local fFuzz = RandomFloat(-0.1, 0.1) -- Adds some timing separation to these magi
    return 0.5 + fFuzz
end
--------------------------------------------------------------------------------
function CastPoisonNova()
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = novaAbility:entindex(),
        Queue = false,
    })
    return 0.5
end
--------------------------------------------------------------------------------
--读条加血
function RestoreHeal(key)
    local caster = key.caster
    caster:Heal(caster:GetMaxHealth(), caster)
    caster:RemoveGesture(ACT_DOTA_FLAIL)
end
--------------------------------------------------------------------------------
--动作
function StartGesture(key)
    local caster = key.caster

    Timers:CreateTimer({
        endTime = 0.3,
        callback = function()
            caster:StartGesture(ACT_DOTA_FLAIL)
            if caster:IsAlive() and caster:FindAbilityByName("creature_venom_channel_heal"):IsChanneling() then
                return 0.7
            else
                caster:RemoveGesture(ACT_DOTA_FLAIL)
                return nil
            end
        end
    })
end