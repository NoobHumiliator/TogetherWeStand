
--[[ units/ai/ai_ice_boss.lua ]]

FLIGHT_DISTANCE = 2000
DEFAULT_FLYBYS = 2
MAX_FLYBYS = 4
LAND_DURATION = 15.0
EGG_HATCH_TIME = 10.0


--------------------------------------------------------------------------------
LinkLuaModifier( "modifier_ice_boss_passive", "creature_ability/modifier/modifier_ice_boss_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ice_boss_trapping_shards", "creature_ability/modifier/modifier_ice_boss_trapping_shards", LUA_MODIFIER_MOTION_NONE )

function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	thisEntity:AddNewModifier( nil, nil, "modifier_invulnerable", { duration = -1 } )

	thisEntity.hShatterProjectile = thisEntity:FindAbilityByName( "ice_boss_shatter_projectile" )
	thisEntity.hFlyingShatterProjectile = thisEntity:FindAbilityByName( "ice_boss_flying_shatter_blast" )
	thisEntity.hTakeFlight = thisEntity:FindAbilityByName( "ice_boss_take_flight" )
	thisEntity.hLand = thisEntity:FindAbilityByName( "ice_boss_land" )
	thisEntity.hWintersCurse = thisEntity:FindAbilityByName( "ice_boss_projectile_curse" )

	thisEntity.FlightPositions = {}

    local homeVector= Entities:FindByName(nil,"waypoint_middle1" ):GetAbsOrigin()

	for i=0,11 do
		local vDirection = RotatePosition( Vector( 0, 0, 0 ), QAngle( 0, i * 30 , 0 ), Vector( 1, 0, 0 ) ) * FLIGHT_DISTANCE
		local vFlightPos = homeVector + vDirection
		table.insert( thisEntity.FlightPositions, vFlightPos )
	end

	thisEntity.vFlightPosition = nil
	thisEntity.nCurrentFlybys = 0
	thisEntity.bLandPending = false
	thisEntity.flNextTakeOffTime = GameRules:GetGameTime()
	thisEntity.numEggsKilled = 0
	thisEntity.bEggDied = false
	thisEntity.nEggsToCreate = 0
    thisEntity.nFlightTimes=0


	thisEntity:SetContextThink( "IceBossThink", IceBossThink, 0.5 )
end



--------------------------------------------------------------------------------

function IceBossThink()
	if not IsServer() then
		return
	end

	if ( not thisEntity:IsAlive() ) then
		return 0.5
	end

	if GameRules:IsGamePaused() == true then
		return 0.5
	end

	if thisEntity.bStarted == false then
		return 0.1
	elseif ( not thisEntity.bInitialInvulnRemoved ) then
		thisEntity:RemoveModifierByName( "modifier_invulnerable" )
		--print( "removed invuln modifier from ice boss" )
		thisEntity.bInitialInvulnRemoved = true
	end

	if thisEntity:FindModifierByName( "modifier_ice_boss_land" ) ~= nil then
		return 0.25
	end

	local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 3000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
	local bFlying =  ( thisEntity:FindModifierByName( "modifier_ice_boss_take_flight" ) ~= nil )
	local bWantsToFly = WantsToFly( bFlying )

	if bFlying ~= bWantsToFly then
		if bFlying then
			if thisEntity.bLandPending == false then
				--随机一个为位置准备降落
				local x= RandomInt(world_left_x,world_right_x)
				local y= RandomInt(world_left_y,world_right_y)
				local vector=GetGroundPosition(Vector(x,y,0),nil)

				thisEntity.vFlightPosition = vector

				thisEntity.bLandPending = true
			end
			return FlyingThink()
		else
			thisEntity.nCurrentFlybys = 0
			thisEntity.bEggDied = false
			return TakeFlight()
		end
	else
		if bFlying then
			return FlyingThink()
		else
			if #enemies>0 then --如果3000范围内有敌人
			    return GroundThink( enemies )
		    else
		    	return AttackNearestEnemy()
		    end
		end
	end

	return 0.1
end

--------------------------------------------------------------------------------

function WantsToFly( bFlying )
	if thisEntity:FindModifierByName( "modifier_ice_boss_land" ) ~= nil or thisEntity.bLandPending == true then
		return false
	end
	if thisEntity.flNextTakeOffTime > GameRules:GetGameTime() then
		return false
	end
	if thisEntity.nCurrentFlybys > MAX_FLYBYS and bFlying then
		return false
	end
	if thisEntity.nCurrentFlybys >= DEFAULT_FLYBYS and thisEntity.bEggDied and bFlying then
		return false
	end

	return true
end

--------------------------------------------------------------------------------

function TakeFlight()
	if thisEntity:FindModifierByName( "modifier_ice_boss_land" ) ~= nil then
		return 0.25
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hTakeFlight:entindex(),
		Queue = false,
	})
	thisEntity.nFlightTimes=thisEntity.nFlightTimes+1
	return 0.25
end

--------------------------------------------------------------------------------

function CastLand()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hLand:entindex(),
		Queue = false,
	})
	return 0.25
end

--------------------------------------------------------------------------------

function GetNumEggsToHatch()

	return thisEntity.nFlightTimes*2+4

end

--------------------------------------------------------------------------------

function FlyingThink()
	if thisEntity:FindModifierByName( "modifier_ice_boss_take_flight" ) == nil then
		return TakeFlight()
	end

	if thisEntity.vFlightPosition == nil then
		--print( "Position is null, calculating new pos" )
		local PotentialPositions = {}
		for _,vPos in pairs ( thisEntity.FlightPositions ) do
			local flDist = ( vPos - thisEntity:GetOrigin() ):Length2D()
			if flDist > ( FLIGHT_DISTANCE + 2000 ) then
				table.insert( PotentialPositions, vPos )
			end
		end

		--print( #PotentialPositions )
		if #PotentialPositions == 0 then
			thisEntity.vFlightPosition = thisEntity.FlightPositions[RandomInt( 1, #thisEntity.FlightPositions )]
		else
			thisEntity.vFlightPosition = PotentialPositions[RandomInt( 1, #PotentialPositions)]
		end
	else
		local flDist = ( thisEntity.vFlightPosition - thisEntity:GetOrigin() ):Length2D()
		if flDist < 200 then
			if thisEntity.bLandPending == true then
				--print( "Landing" )
				return CastLand()
			end
			--print( "Reached flight target" )
			thisEntity.vFlightPosition = nil
			thisEntity.nCurrentFlybys = thisEntity.nCurrentFlybys + 1
            if thisEntity.nCurrentFlybys==2 then --固定第二次停住的位置生蛋

                --落地孵蛋
				local nEggsToCreate = GetNumEggsToHatch()
				while nEggsToCreate > 0 do
					CreateUnitByName( "npc_dota_creature_ice_boss_egg", thisEntity:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS )
					nEggsToCreate = nEggsToCreate - 1
			    end

            end

			return 0.25
		else
			--print ( "Looking for enemies ")
			local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 600, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BUILDING, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
			if #enemies ~= 0 and thisEntity.nCurrentFlybys > 0 then
				return CastFlyingShatterProjectile()
			end
		end
	end

	return Fly()
end

--------------------------------------------------------------------------------

function Fly()

	--print( "Flying to position" )
	--print( "thisEntity.vFlightPosition: ( " .. thisEntity.vFlightPosition.x .. ", " .. thisEntity.vFlightPosition.y .. ", " .. thisEntity.vFlightPosition.z .. ")"  )
		ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = thisEntity.vFlightPosition
	})
	return 0.25
end

--------------------------------------------------------------------------------

function CastFlyingShatterProjectile()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = thisEntity.hFlyingShatterProjectile:entindex(),
		Queue = false,
	})
	return 0.33
end

--------------------------------------------------------------------------------

function GroundThink( enemies )
	if #enemies == 0 then
		return 0.25
	end

	if thisEntity:FindModifierByName( "modifier_ice_boss_land" ) ~= nil then
		return 0.25
	end

	if thisEntity.bLandPending == true then
		thisEntity.bLandPending = false
        thisEntity.flNextTakeOffTime = GameRules:GetGameTime() + LAND_DURATION
		local eggs = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_FARTHEST, false )
		for _, egg in pairs( eggs ) do
			if egg:IsAlive() then
				local hBuff = egg:FindModifierByName( "modifier_ice_boss_egg_passive" )
				if hBuff ~= nil and hBuff.bHatching == false then
					local ability = egg:FindAbilityByName( "ice_boss_egg_passive" )
					if ability ~= nil then
						ability:LaunchHatchProjectile( thisEntity )
					end
				end
			end
		end
	end

	if thisEntity.hWintersCurse ~= nil and thisEntity.hWintersCurse:IsFullyCastable() then
		return CastWintersCurse( enemies[RandomInt( 1, #enemies)] )
	end

	if thisEntity.hShatterProjectile ~= nil and thisEntity.hShatterProjectile:IsFullyCastable() then
		return CastShatterProjectile( enemies[#enemies]:GetOrigin() )
	end

    AttackNearestEnemy()

	return 0.25
end

----------------------------------------------------------------------------------

function CastWintersCurse( hTarget )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		TargetIndex = hTarget:entindex(),
		AbilityIndex = thisEntity.hWintersCurse:entindex(),
		Queue = false,
	})
	return 1.6
end

--------------------------------------------------------------------------------

function CastShatterProjectile( position )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		Position = position,
		AbilityIndex = thisEntity.hShatterProjectile:entindex(),
		Queue = queue,
	})
	return 1.0
end

---------------------------------------------------------------------------------

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

	return 0.5
end
--------------------------------------------------------------------------------