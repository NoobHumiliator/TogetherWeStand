function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

	SmashAbility = thisEntity:FindAbilityByName( "ogre_tank_melee_smash" )
	JumpAbility = thisEntity:FindAbilityByName( "ogre_tank_jump_smash" )
	thisEntity:SetContextThink( "OgreTankThink", OgreTankThink, 1 )
end

function OgreTankThink()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end
	
	if GameRules:IsGamePaused() == true then
		return 1
	end

	-- Increase acquisition range after the initial aggro
	if ( not thisEntity.bAcqRangeModified ) and thisEntity:GetAggroTarget() then
		thisEntity:SetAcquisitionRange( 850 )
		thisEntity.bAcqRangeModified = true
	end

	local nEnemiesRemoved = 0
	local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
	for i = 1, #enemies do
		local enemy = enemies[i]
		if enemy ~= nil then
			local flDist = ( enemy:GetOrigin() - thisEntity:GetOrigin() ):Length2D()
			if flDist < 300 then
				nEnemiesRemoved = nEnemiesRemoved + 1
				table.remove( enemies, i )
			end
		end
	end

	if JumpAbility ~= nil and JumpAbility:IsFullyCastable() and nEnemiesRemoved > 0 then
		return Jump()
	end


	if SmashAbility ~= nil and SmashAbility:IsFullyCastable() and #enemies>0  then
		return Smash( enemies[ 1 ] )
	end
	
	return AttackNearestEnemy()
	
end


function Jump()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = JumpAbility:entindex(),
		Queue = false,
	})
	
	return 2.5
end


function Smash( enemy )
	if enemy == nil then
		return
	end

	if ( not thisEntity:HasModifier( "modifier_provide_vision" ) ) then
		--print( "If player can't see me, provide brief vision to his team as I start my Smash" )
		thisEntity:AddNewModifier( thisEntity, nil, "modifier_provide_vision", { duration = 1.5 } )
	end

	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = SmashAbility:entindex(),
		Position = enemy:GetOrigin(),
		Queue = false,
	})

	return 3 / thisEntity:GetHasteFactor()
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

	local fFuzz = RandomFloat( -0.1, 0.1 ) -- Adds some timing separation to these magi
	return 0.5 + fFuzz
end
--------------------------------------------------------------------------------