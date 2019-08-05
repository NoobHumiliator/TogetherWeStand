
--[[ units/ai/ai_exploding_burrower.lua ]]

----------------------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if thisEntity == nil then
		return
	end

	hExplosionAbility = thisEntity:FindAbilityByName( "big_exploding_burrower_big_explosion" )

	thisEntity:SetContextThink( "ExplodingNyxThink", ExplodingNyxThink, 0.5 )
end

----------------------------------------------------------------------------------------------

function ExplodingNyxThink()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 1
	end

	local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
	if #hEnemies > 0 then
		local enemy = hEnemies[1]
			local flDist = ( enemy:GetOrigin() - thisEntity:GetOrigin() ):Length2D()
			if flDist <= 150 then
				return CastExplosion()
			else
				return Approach( enemy )
			end
	end

	return 0.5
end

----------------------------------------------------------------------------------------------

function CastBurrow()
	--print( "ExplodingBurrower - CastBurrow()" )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = hBurrowAbility:entindex(),
	})
	return 2
end

----------------------------------------------------------------------------------------------

function CastUnburrow()
	--print( "ExplodingBurrower - CastUnburrow()" )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = hUnburrowAbility:entindex(),
	})
	return 0.3
end

----------------------------------------------------------------------------------------------

function CastExplosion()
	--print( "ExplodingBurrower - CastExplosion()" )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = hExplosionAbility:entindex(),
		Queue = false,
	})
	return 2
end

----------------------------------------------------------------------------------------------

function Approach( unit )
	--print( "ExplodingBurrower - Approach()" )
	local vToEnemy = unit:GetOrigin() - thisEntity:GetOrigin()
	vToEnemy = vToEnemy:Normalized()

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = thisEntity:GetOrigin() + vToEnemy * thisEntity:GetIdealSpeed()
	})
	return 0.4
end

----------------------------------------------------------------------------------------------
