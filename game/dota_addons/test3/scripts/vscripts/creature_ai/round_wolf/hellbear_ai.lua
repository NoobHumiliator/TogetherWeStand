--[[
razor AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
		thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
		smashAbility = thisEntity:FindAbilityByName( "hellbear_smash" )
	    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorSmash} )
    end
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

function CollectRetreatMarkers()
	local result = {}
	local i = 1
	local wp = nil
	while true do
		wp = Entities:FindByName( nil, string.format("waypoint_%d", i ) )
		if not wp then
			return result
		end
		table.insert( result, wp:GetOrigin() )
		i = i + 1
	end
end
POSITIONS_retreat = CollectRetreatMarkers()

--------------------------------------------------------------------------------------------------------
BehaviorNone = {}
function BehaviorNone:Evaluate()
	return 2 -- must return a value > 0, so we have a default ¿ØÖÆ´ó·½Ïò£¬ÍùÒ»¸ö×î½üµÄÓ¢ÐÛ´¦¿¿½ü
end

function BehaviorNone:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.target=nil
	local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		if #allEnemies > 0 then
			self.target = allEnemies[1]
		end


	if self.target and self.target:IsAlive() then
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position =  self.target:GetOrigin()
		}
	else
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP
		}
	end
end

 BehaviorNone.Continue=BehaviorNone.Begin

--------------------------------------------------------------------------------------------------------

BehaviorSmash = {}

function BehaviorSmash:Evaluate()

	local desire = 0
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	if smashAbility and smashAbility:IsFullyCastable() then
		local target = AICore:RandomEnemyHeroInRange( thisEntity, 350 )
		if target then
			desire = 3
		end
	end
	return desire

end

function BehaviorSmash:Begin()

	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = smashAbility:entindex()
	}

end

BehaviorSmash.Continue = BehaviorSmash.Begin

--------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorSmash}
