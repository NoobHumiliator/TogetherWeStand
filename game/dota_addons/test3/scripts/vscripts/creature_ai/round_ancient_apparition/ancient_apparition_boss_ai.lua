
function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	IceAgeAbility = thisEntity:FindAbilityByName( "boss_ancient_apparition_ice_age" )
	ThornAbility = thisEntity:FindAbilityByName( "boss_ancient_apparition_ice_thorn" )
    BeamAbility = thisEntity:FindAbilityByName( "boss_ancient_apparition_beam" )

	thisEntity:SetContextThink( "AncientApparitionBossThink", AncientApparitionBossThink, 1 )
end

function AncientApparitionBossThink()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end
	
	if GameRules:IsGamePaused() == true then
		return 1
	end
    
    -- 引导激光
    if thisEntity:IsChanneling() == true then
		return 0.5
	end

    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	
	if #enemies > 0 then
        if BeamAbility ~= nil and BeamAbility:IsFullyCastable() then
		   return Beam(enemies[1])
	    end
    end
    

	if ThornAbility ~= nil and ThornAbility:IsFullyCastable() then
		return Thorn()
	end

    --至少有一个尖刺
	if IceAgeAbility ~= nil and IceAgeAbility:IsFullyCastable() and thisEntity.vThornThinkers and #thisEntity.vThornThinkers>0 then
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

	local target
	local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	if #allEnemies > 0 then
		local minDistance = 10000000
		for _,enemy in pairs(allEnemies) do
			local distance = ( thisEntity:GetOrigin() - enemy:GetOrigin() ):Length()
			if distance < minDistance then
			  minDistance=distance
              target=enemy
			end
		end
	end

    if target~=nil and not thisEntity:IsAttacking() then  --避免打断攻击动作

		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = target:GetOrigin()
		})

    end

	return 0.5 
end
--------------------------------------------------------------------------------