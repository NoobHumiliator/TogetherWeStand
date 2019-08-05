--[[ units/ai/ai_centaur_warlord.lua ]]
--------------------------------------------------------------------------------
function Spawn(entityKeyValues)
    if not IsServer() then
        return
    end

    if thisEntity == nil then
        return
    end

    thisEntity.hHoofStompAbility = thisEntity:FindAbilityByName("creature_centaur_warlord_hoof_stomp")
    thisEntity.hDoubleEdgeAbility = thisEntity:FindAbilityByName("creature_centaur_warlord_double_edge")
    thisEntity.hStampedeAbility = thisEntity:FindAbilityByName("creature_centaur_warlord_stampede")

    thisEntity:SetContextThink("CentaurWarlordThink", CentaurWarlordThink, 0.5)
end

--------------------------------------------------------------------------------
function CentaurWarlordThink()
    if not IsServer() then
        return
    end

    -- Search for items here instead of in Spawn, because they don't seem to exist yet when Spawn runs
    if not thisEntity.bSearchedForItems then
        SearchForItems()
        thisEntity.bSearchedForItems = true
    end

    if (not thisEntity:IsAlive()) then
        return -1
    end

    if GameRules:IsGamePaused() == true then
        return 0.5
    end

    local hEnemies = FindUnitsInRadius(thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 550, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false)
    if #hEnemies > 0 then
        -- @fixme: need to check if we have an enemy within 550 radius
        if thisEntity.hHoofStompAbility ~= nil and thisEntity.hHoofStompAbility:IsFullyCastable() then
            if (thisEntity:GetHealthPercent() < 80) then
                return CastHoofStomp()
            end
        end

        if thisEntity.hDoubleEdgeAbility ~= nil and thisEntity.hDoubleEdgeAbility:IsFullyCastable() then
            return CastDoubleEdge(hEnemies[RandomInt(1, #hEnemies)])
        end

        --[[		if ( #hEnemies >= 1 ) and thisEntity.hBlademailAbility and thisEntity.hBlademailAbility:IsFullyCastable() then
			if ( thisEntity:GetHealthPercent() < 65 ) then
				return UseBlademail()
			end
		end
		]]
        return 0.5
    else
        return AttackNearestEnemy()
    end

end

--------------------------------------------------------------------------------
function SearchForItems()
    for i = 0, 5 do
        local item = thisEntity:GetItemInSlot(i)
        if item then
            if item:GetAbilityName() == "item_blade_mail" then
                thisEntity.hBlademailAbility = item
            end
        end
    end
end

--------------------------------------------------------------------------------
function CastHoofStomp()
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.hHoofStompAbility:entindex(),
        Queue = false,
    })
    return 2
end

--------------------------------------------------------------------------------
function CastDoubleEdge(hEnemy)
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
        TargetIndex = hEnemy:entindex(),
        AbilityIndex = thisEntity.hDoubleEdgeAbility:entindex(),
        Queue = false,
    })
    return 2
end

--------------------------------------------------------------------------------
function CastStampede()
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.hStampedeAbility:entindex(),
        Queue = false,
    })
    return 2
end

--------------------------------------------------------------------------------
function UseBlademail()
    ExecuteOrderFromTable({
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = thisEntity.hBlademailAbility:entindex(),
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
--------------------------------------------------------------------------------