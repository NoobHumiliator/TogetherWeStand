--[[
Lion BOSS的AI
]]


require( "ai_core" )
require("addon_game_mode")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone,BehaviorHex,BehaviorImpale,BehaviorFinger} ) 
      if thisEntity:HasAbility("lion_boss_hex") then
      	 local ability=thisEntity:FindAbilityByName("lion_boss_hex")
      	 ability:StartCooldown(20)
      	 ability:ApplyDataDrivenModifier(thisEntity, thisEntity, "modifier_temp_fly", {duration=20})
      end
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
BehaviorHex = {}

function BehaviorHex:Evaluate()  --妖术
	local desire = 0
	if currentBehavior == self then return desire end
	self.plasmaAbility = thisEntity:FindAbilityByName("lion_boss_hex")
	if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
		desire = 7
	end	
	return desire
end

function BehaviorHex:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.plasmaAbility:entindex()
	}

end
BehaviorHex.Continue = BehaviorHex.Begin
--------------------------------------------------------------------------------------------------------
BehaviorImpale = {}

function BehaviorImpale:Evaluate()    --旋转尖刺
	local desire = 0
	
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.impaleAbility = thisEntity:FindAbilityByName( "lion_boss_impale_circular" )
	
	if self.impaleAbility and self.impaleAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRange( thisEntity, 1000)
		if self.target then
			desire = 5
		end
	end	
	return desire
end

function BehaviorImpale:Begin()
	self.endTime = GameRules:GetGameTime() + 1	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.impaleAbility:entindex()
	}

end
BehaviorImpale.Continue = BehaviorImpale.Begin
--------------------------------------------------------------------------------------------------------
BehaviorFinger = {}

function BehaviorFinger:Evaluate()    --死亡一指
	local desire = 0
	if currentBehavior == self then return desire end
	self.fingerAbility = thisEntity:FindAbilityByName("lion_boss_finger_of_death")
	if self.fingerAbility and self.fingerAbility:IsFullyCastable() then
		desire = 3
	end	
	return desire
end

function BehaviorFinger:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.fingerAbility:entindex()
	}

end
BehaviorFinger.Continue = BehaviorFinger.Begin
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = {BehaviorNone ,BehaviorHex,BehaviorImpale,BehaviorFinger}

