require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone,BehaviorIceShards,BehaviorKick} )
    end
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

--------------------------------------------------------------------------------------------------------
BehaviorNone = {}
function BehaviorNone:Evaluate()
	return 2 -- must return a value > 0, so we have a default 控制大方向，往一个最近的英雄处靠近
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
BehaviorIceShards = {}  --冰片

function BehaviorIceShards:Evaluate()
	self.shardsAbility = thisEntity:FindAbilityByName("tws_tusk_ice_shards")
	local target =nil
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.shardsAbility and self.shardsAbility:IsFullyCastable() then
		local range = self.shardsAbility:GetCastRange()
		target = AICore:RandomEnemyHeroInRangeNotIllusionIgnoreImmnue( thisEntity, range )
	end

	if target then
		desire = 8
		self.target = target
        self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
			UnitIndex = thisEntity:entindex(),
			Position = target:GetOrigin() + RandomVector(25),
			AbilityIndex = self.shardsAbility:entindex()
		}
	else
		desire = 1
	end

	return desire
end

function BehaviorIceShards:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

BehaviorIceShards.Continue = BehaviorIceShards.Begin
--------------------------------------------------------------------------------------------------------
BehaviorKick = {}  --海象飞踢

function BehaviorKick:Evaluate()
	self.kickAbility = thisEntity:FindAbilityByName("tws_tusk_walrus_punch")
	local target =nil
	local desire = 0

	if AICore.currentBehavior == self then return desire end

	if self.kickAbility and self.kickAbility:IsFullyCastable() then
		local range = self.kickAbility:GetCastRange()
		target = AICore:RandomEnemyHeroInRangeNotIllusionIgnoreImmnue( thisEntity, range )
	end

	if target then
		desire = 6
		self.target = target
        self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			UnitIndex = thisEntity:entindex(),
			TargetIndex = target:entindex(),
			AbilityIndex = self.kickAbility:entindex()
		}
	else
		desire = 1
	end

	return desire
end

function BehaviorKick:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

BehaviorKick.Continue = BehaviorKick.Begin
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone,BehaviorIceShards,BehaviorKick}

