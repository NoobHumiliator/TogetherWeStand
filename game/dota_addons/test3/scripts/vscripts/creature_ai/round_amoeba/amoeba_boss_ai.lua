function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    if IsServer() == false then
        return
    end

    if thisEntity:GetUnitName() == "npc_dota_creature_amoeba_boss" then
        thisEntity:AddNewModifier(nil, nil, "modifier_kill", { duration = 360 })  --设置强制死亡时间,6分钟 防止玩家无限刷小怪
    end

    thisEntity:AddNewModifier(thisEntity, nil, "modifier_provide_vision", {}) --提供视野，避免出现卡在树林里玩家找不到

    FuseAbility = thisEntity:FindAbilityByName("amoeba_fuse")
    BlobLaunchAbility = thisEntity:FindAbilityByName("amoeba_blob_launch")
    BlobJumpSmashAbility = thisEntity:FindAbilityByName("amoeba_boss_jump_splatter")
    BlobSplitAbility = thisEntity:FindAbilityByName("amoeba_boss_split")


    thisEntity.bCooldownsFlipped = false
    thisEntity:SetContextThink("AmoebaThink", AmoebaThink, 1)
end

function AmoebaThink()
    if GameRules:IsGamePaused() == true then
        return 1
    end

    local hMyBuff = thisEntity:FindModifierByName("modifier_amoeba_boss_passive")
    if hMyBuff == nil then
        return 1
    end

    --设置部分初始冷却  分裂10秒，吐水3秒
    if thisEntity.bCooldownsFlipped == false then
        thisEntity.bCooldownsFlipped = true
        if BlobLaunchAbility ~= nil then
            BlobLaunchAbility:StartCooldown(3)
        end
        if BlobSplitAbility ~= nil then
            BlobSplitAbility:StartCooldown(10)
        end
    end

    local enemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
    local jumpEnemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)


    local friendlies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 1200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)

    local nStackCount = hMyBuff:GetStackCount()
    if nStackCount > 50 then
        return BigAmoebaThink(nStackCount, enemies, jumpEnemies)
    end
    if nStackCount <= 50 and nStackCount > 25 then
        return MediumAmoebaThink(nStackCount, enemies, jumpEnemies)
    end

    return SmallAmoebaThink(nStackCount, friendlies, enemies)
end

function BigAmoebaThink(nStackCount, enemies, jumpEnemies)
    local hBlobTarget = GetLaunchBlobTarget(enemies)
    local hJumpTarget = GetLaunchBlobTarget(jumpEnemies)
    --print("hJumpTarget"..hJumpTarget:GetUnitName())
    if BlobSplitAbility ~= nil and BlobSplitAbility:IsFullyCastable() and nStackCount > 150 and thisEntity:GetHealthPercent() < 85 then
        return Split()
    end
    if BlobJumpSmashAbility ~= nil and BlobJumpSmashAbility:IsFullyCastable() and hJumpTarget ~= nil then
        return JumpSmash(hJumpTarget)
    end
    if BlobLaunchAbility ~= nil and BlobLaunchAbility:IsFullyCastable() and hBlobTarget ~= nil then
        return LaunchBlob(hBlobTarget)
    end
    return AttackNearestEnemy()
end

function MediumAmoebaThink(nStackCount, enemies, jumpEnemies)
    local hBlobTarget = GetLaunchBlobTarget(enemies)
    local hJumpTarget = GetLaunchBlobTarget(jumpEnemies)


    if BlobJumpSmashAbility ~= nil and BlobJumpSmashAbility:IsFullyCastable() and hJumpTarget ~= nil then
        return JumpSmash(hJumpTarget)
    end

    return AttackNearestEnemy()
end

function SmallAmoebaThink(nStackCount, friendlies, enemies)
    local hNearestAmoeba = nil
    if RollPercentage(5) then
        for _, friendly in pairs(friendlies) do
            if friendly ~= nil then
                local hOtherEntBuff = friendly:FindModifierByName("modifier_amoeba_boss_passive")
                if hOtherEntBuff ~= nil and (hOtherEntBuff:GetStackCount() > 50) then
                    return Fuse(friendly)
                end
            end
        end
    end


    local hBlobTarget = GetLaunchBlobTarget(enemies)
    if BlobJumpSmashAbility ~= nil and BlobJumpSmashAbility:IsFullyCastable() and hBlobTarget ~= nil and ((_G.hBossAmoeba and not hBossAmoeba:IsNull() and _G.hBossAmoeba:IsAlive() and _G.hBossAmoeba:GetHealthPercent() < 50) or (thisEntity:GetTeamNumber() == DOTA_TEAM_GOODGUYS)) then
        return JumpSmash(hBlobTarget)
    end

    return AttackNearestEnemy()
end

function TryFuse(nStackCount, hClosestEnt)
    if hClosestEnt ~= nil and hClosestEnt:GetTeamNumber() == thisEntity:GetTeamNumber() then
        local hOtherEntBuff = hClosestEnt:FindModifierByName("modifier_amoeba_boss_passive")
        if hOtherEntBuff ~= nil and (hOtherEntBuff:GetStackCount() >= nStackCount) then
            return true
        end
    end
    return false
end

function GetLaunchBlobTarget(entities)
    local hFarthestEnemy = nil
    for _, ent in pairs(entities) do
        if ent ~= nil and ent:GetTeamNumber() ~= thisEntity:GetTeamNumber() then
            hFarthestEnemy = ent
        end
    end

    return hFarthestEnemy
end

function Fuse(friendly)
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
        TargetIndex = friendly:entindex(),
        AbilityIndex = FuseAbility:entindex(),
        Queue = false,
    })
    return 10
end

function LaunchBlob(enemy)
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        Position = enemy:GetOrigin(),
        AbilityIndex = BlobLaunchAbility:entindex(),
        Queue = false,
    })
    return 5
end

function JumpSmash(enemy)
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        Position = enemy:GetOrigin(),
        AbilityIndex = BlobJumpSmashAbility:entindex(),
        Queue = false,
    })
    return 1
end

function Split()
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = BlobSplitAbility:entindex(),
        Queue = false,
    })
    return 1
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