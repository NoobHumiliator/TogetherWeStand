
--------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity.hFreezingBlast = thisEntity:FindAbilityByName( "frostbitten_freezing_blast" )

	thisEntity:SetContextThink( "FrostbittenRangedThink", FrostbittenRangedThink, 0.5 )
end

--------------------------------------------------------------------------------

function FrostbittenRangedThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, thisEntity.hFreezingBlast:GetCastRange( thisEntity:GetOrigin(), nil ), DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )

	if   #hEnemies >0 and thisEntity.hFreezingBlast ~= nil and thisEntity.hFreezingBlast:IsFullyCastable() then
		return CastFreezingBlast( hEnemies[ #hEnemies ] )
	end

	return AttackNearestEnemy()
end

--------------------------------------------------------------------------------

function CastFreezingBlast( hTarget )
	thisEntity:AddNewModifier( thisEntity, nil, "modifier_provide_vision", { duration = 1.1 } )

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hTarget:entindex(),
		AbilityIndex = thisEntity.hFreezingBlast:entindex(),
		Queue = false,
	})

	return 1
end

--------------------------------------------------------------------------------

function CastFrostArmor( hAlly )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hAlly:entindex(),
		AbilityIndex = thisEntity.hFrostArmor:entindex(),
		Queue = false,
	})

	return 0.5
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
function AttackNearestEnemy()  --攻击最近的目标

	local target = nil
	local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	if #allEnemies > 0 then
		target = allEnemies[1]
	end

    if target~=nil and not thisEntity:IsAttacking() then  --避免打断攻击动作

		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position = target:GetOrigin()
		})

    end

	local fFuzz = RandomFloat( -0.1, 0.1 ) -- Adds some timing separation to these magi
	return 0.5 + fFuzz
end
--------------------------------------------------------------------------------