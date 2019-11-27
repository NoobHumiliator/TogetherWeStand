--[[
TK BOSS的AI
]]


require( "ai_core" )
require("addon_game_mode")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone,BehaviorTech,BehaviorLaser,BehaviorMissile,BehaviorMarch} )
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
BehaviorTech = {}

function BehaviorTech:Evaluate()  --召唤炸弹人
	local desire = 0
	if currentBehavior == self then return desire end
	self.plasmaAbility = thisEntity:FindAbilityByName("tinker_boss_spawn_techies")
	if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
		desire = 6
	end
	return desire
end

function BehaviorTech:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.plasmaAbility:entindex()
	}

end
BehaviorTech.Continue = BehaviorTech.Begin
--------------------------------------------------------------------------------------------------------
BehaviorLaser = {}

function BehaviorLaser:Evaluate()    --激光炮台
	local desire = 0

	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.impaleAbility = thisEntity:FindAbilityByName( "tinker_boss_spawn_laser_turret" )

	if self.impaleAbility and self.impaleAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRangeIgnoreImmnue( thisEntity, 1500)
		if self.target then
			desire = 5
		end
	end
	return desire
end

function BehaviorLaser:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.impaleAbility:entindex()
	}

end
BehaviorLaser.Continue = BehaviorLaser.Begin
--------------------------------------------------------------------------------------------------------
BehaviorMissile = {}

function BehaviorMissile:Evaluate()    --热导飞弹
	local desire = 0
	if currentBehavior == self then return desire end
	self.missileAbility = thisEntity:FindAbilityByName("tinker_boss_heatmissile")
	if self.missileAbility and self.missileAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRangeIgnoreImmnue( thisEntity, 800)
		if self.target then
			desire = 4
		end
	end
	return desire
end

function BehaviorMissile:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.missileAbility:entindex()
	}

end
BehaviorMissile.Continue = BehaviorMissile.Begin
--------------------------------------------------------------------------------------------------------
BehaviorMarch = {}   --机器人进军

function BehaviorMarch:Evaluate()
	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end
	self.marchAbility = thisEntity:FindAbilityByName("tinker_boss_march_of_the_machines")
	local desire = 0
	local range = self.marchAbility:GetCastRange()
    local target = AICore:RandomEnemyHeroInRangeIgnoreImmnue(thisEntity,range)   --范围对内随机英雄附近使用机器人进军

	if self.marchAbility and self.marchAbility:IsFullyCastable() and target then
		desire = 3
		self.target = target
        local targetPoint = self.target:GetOrigin() + RandomVector(50)

	    self.order =
	   {
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.marchAbility:entindex(),
		Position = targetPoint
	   }
	else
		desire = 1
	end

	return desire
end

function BehaviorMarch:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

BehaviorMarch.Continue = BehaviorMarch.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = {BehaviorNone ,BehaviorTech,BehaviorLaser,BehaviorMissile,BehaviorMarch}

