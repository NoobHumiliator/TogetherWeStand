
require( "ai_core" )
----------------------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if IsServer() then
		if thisEntity == nil then
			return
		end

		thisEntity.GIANT_BURROWER_SUMMONED_UNITS = { }
		thisEntity.GIANT_BURROWER_MAX_SUMMONS = 20

		hImpaleAbility = thisEntity:FindAbilityByName( "creature_giant_nyx_burrower_impale" )
		hMinionSpawnerAbility = thisEntity:FindAbilityByName( "creature_giant_nyx_burrower_minion_spawner" )

		thisEntity:SetContextThink( "GiantBurrowerThink", GiantBurrowerThink, 1 )
	end
end

----------------------------------------------------------------------------------------------

function GiantBurrowerThink()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 1
	end


	if hMinionSpawnerAbility ~= nil and hMinionSpawnerAbility:IsFullyCastable() then
		 return CastMinionSpawner()
	end

    local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 1050, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
    if  #hEnemies > 0 then
		if hImpaleAbility ~= nil and hImpaleAbility:IsFullyCastable() then
			return CastImpale( hEnemies[ RandomInt( 1, #hEnemies ) ] )
		end
	end

    return AttackNearestEnemy(thisEntity)

end

----------------------------------------------------------------------------------------------
function CastImpale( unit )
	--print( "GiantBurrower - CastImpale()" )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = hImpaleAbility:entindex(),
		Position = unit:GetOrigin(),
		Queue = false,
	})
	return 2
end

----------------------------------------------------------------------------------------------

function CastMinionSpawner()
	--print( "GiantBurrower - CastMinionSpawner()" )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = hMinionSpawnerAbility:entindex(),
	})
	return 2
end
--------------------------------------------------------------------------------