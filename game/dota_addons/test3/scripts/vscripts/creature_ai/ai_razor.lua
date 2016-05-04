--[[
razor AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorStatic_Link, BehaviorPlasma_Field} ) 
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
	local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		if #allEnemies > 0 then
			local minDistance = 10000000
			for _,enemy in pairs(allEnemies) do
				local distance = ( thisEntity:GetOrigin() - enemy:GetOrigin() ):Length()
				if distance < minDistance then
				  minDistance=distance
                  self.target=enemy
				end
			end
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

BehaviorPlasma_Field = {}

function BehaviorPlasma_Field:Evaluate()
	local desire = 0
	
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.plasmaAbility = thisEntity:FindAbilityByName( "creature_plasma_field" )
	
	if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRange( thisEntity, 600 )
		if self.target then
			desire = 6
		end
	end	
	return desire
end

function BehaviorPlasma_Field:Begin()
	self.endTime = GameRules:GetGameTime() + 1	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.plasmaAbility:entindex()
	}

end

BehaviorPlasma_Field.Continue = BehaviorPlasma_Field.Begin

--------------------------------------------------------------------------------------------------------
BehaviorStatic_Link = {}

function BehaviorStatic_Link:Evaluate()
	self.staticlinkAbility = thisEntity:FindAbilityByName("creature_static_link")    --压制
	local target=nil
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() then  
		local range = self.staticlinkAbility:GetCastRange()
		target = AICore:RandomEnemyHeroInRangeNotIllusionIgnoreImmnue( thisEntity, range )
	end

	if target then
		desire = 7
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorStatic_Link:Begin()
	self.endTime = GameRules:GetGameTime() + 3
        self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			UnitIndex = thisEntity:entindex(),
			TargetIndex = self.target:entindex(),
			AbilityIndex = self.staticlinkAbility:entindex()
		}
end 

BehaviorStatic_Link.Continue = BehaviorStatic_Link.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

--------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorStatic_Link, BehaviorPlasma_Field}
