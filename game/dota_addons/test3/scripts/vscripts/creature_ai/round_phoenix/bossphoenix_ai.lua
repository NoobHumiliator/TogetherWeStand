--[[
蓝龙BOSS的AI
]]


require( "ai_core" )
require("addon_game_mode")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone,BehaviorPlasma_Field,BehaviorDive} )
      thisEntity:FindAbilityByName("phoenix_boss_supernova_datadriven"):StartCooldown(10.0)  --凤凰蛋 10s  CD
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
BehaviorPlasma_Field = {}

function BehaviorPlasma_Field:Evaluate()
	local desire = 0
	if currentBehavior == self then return desire end
	self.plasmaAbility = thisEntity:FindAbilityByName("phoenix_boss_supernova_datadriven")
	if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
		desire = 3
	end
	return desire
end

function BehaviorPlasma_Field:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.plasmaAbility:entindex()
	}

end
BehaviorPlasma_Field.Continue = BehaviorPlasma_Field.Begin
--------------------------------------------------------------------------------------------------------
--凤凰冲击
BehaviorDive = {}

function BehaviorDive:Evaluate()
	local desire = 0
	if currentBehavior == self then return desire end
	self.diveAbility = thisEntity:FindAbilityByName("phoenix_boss_icarus_dive_datadriven")
    local range = self.diveAbility:GetCastRange()


	self.target = AICore:RandomEnemyHeroInRangeNotIllusion(thisEntity,range)   --范围对内随机非幻象英雄使用穿刺


	if self.target and self.diveAbility and self.diveAbility:IsFullyCastable() then
		desire = 5
	end
	return desire
end

function BehaviorDive:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5

    local targetPoint = self.target:GetOrigin() + RandomVector(50)
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.diveAbility:entindex(),
		Position = targetPoint
	}
end
BehaviorDive.Continue = BehaviorDive.Begin
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = {BehaviorNone ,BehaviorPlasma_Field,BehaviorDive}

