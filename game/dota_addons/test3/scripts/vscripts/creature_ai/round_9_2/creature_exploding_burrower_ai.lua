
--[[ units/ai/ai_exploding_burrower.lua ]]

----------------------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if thisEntity == nil then
		return
	end

	hExplosionAbility = thisEntity:FindAbilityByName( "creature_burrower_explosion" )

	hUnburrowAbility:SetHidden( false )

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


	local hEnemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 150, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
	if #hEnemies > 0 then
	    local hExplosionTarget = hEnemies[1]
		if hExplosionTarget and hExplosionAbility and hExplosionAbility:IsCooldownReady() then
			return CastExplosion()
		end
    else
        return AttackNearestEnemy()
    end
    
	return 0.5
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
	return 1
end
--------------------------------------------------------------------------------

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