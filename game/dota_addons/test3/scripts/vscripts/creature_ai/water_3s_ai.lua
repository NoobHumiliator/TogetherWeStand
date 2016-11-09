--[[
收割形态的水人AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorWishFuse , BehaviorFusing,BehaviorThrowHook,BehaviorDismember,BehaviorAdaptiveStrike} ) 
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
BehaviorWishFuse = {}
function BehaviorWishFuse:Evaluate()
	local desire = 1
	local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin() , nil, 700, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
	local minDistance = 10000000
	    if #targets > 0 then
           for i,unit in pairs(targets) do                 
               if unit:GetUnitName()==("npc_majia_water_1") then
                	local distance = ( thisEntity:GetOrigin() - unit:GetOrigin() ):Length()
                	if distance < minDistance then
				     minDistance=distance
                     self.target=unit
                     desire=9
                    end
               end 
           end
       end   
    return desire
end
function BehaviorWishFuse:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	if self.target and self.target:IsAlive() then
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
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

 BehaviorWishFuse.Continue=BehaviorWishFuse.Begin

function BehaviorWishFuse:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
BehaviorFusing = {}
function BehaviorFusing:Evaluate()
	local desire = 1
	if currentBehavior == self then return desire end

	self.plasmaAbility = thisEntity:FindAbilityByName( "water_fuse" )
	local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin() , nil, 200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
	    if #targets > 0 then
           for i,unit in pairs(targets) do                 
               if unit:GetUnitName()==("npc_majia_water_1") and self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
                     desire=10
               end 
           end
       end   
    return desire
end
function BehaviorFusing:Begin()
	self.endTime = GameRules:GetGameTime() + 1
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = self.plasmaAbility:entindex()
		}
end

 BehaviorFusing.Continue=BehaviorFusing.Begin
--------------------------------------------------------------------------------------------------------
BehaviorThrowHook = {}

function BehaviorThrowHook:Evaluate()
	local desire = 1
	
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end
	self.hookAbility = thisEntity:FindAbilityByName( "water_waveform" )
	local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin() , nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	local MaxDistance = 100
	    if #targets > 0 then
           for i,unit in pairs(targets) do                            
                local distance = ( thisEntity:GetOrigin() - unit:GetOrigin() ):Length()
                if distance > MaxDistance and self.hookAbility and self.hookAbility:IsFullyCastable() then
				     MaxDistance=distance
                     self.target=unit
                     desire=5
                end
           end
       end   	
	return desire
end

function BehaviorThrowHook:Begin()
	self.endTime = GameRules:GetGameTime() + 1

	local targetPoint = self.target:GetOrigin() + RandomVector( 50 )
	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.hookAbility:entindex(),
		Position = targetPoint
	}

end

BehaviorThrowHook.Continue = BehaviorThrowHook.Begin
--------------------------------------------------------------------------------------------------------
BehaviorDismember = {}          ------------------洪流

function BehaviorDismember:Evaluate()
	self.dismemberAbility = thisEntity:FindAbilityByName("water_current")
	local target
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.dismemberAbility and self.dismemberAbility:IsFullyCastable() then
		local range = self.dismemberAbility:GetCastRange()
		target = AICore:RandomEnemyHeroInRange( thisEntity, range )
	end

	if target then
		desire = 4
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorDismember:Begin()
	local targetPoint = self.target:GetOrigin() + RandomVector(50)
	self.endTime = GameRules:GetGameTime() + 1

	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.dismemberAbility:entindex(),
		Position = targetPoint
	}
end

BehaviorDismember.Continue = BehaviorDismember.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorDismember:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
BehaviorAdaptiveStrike = {}  --变体攻击

function BehaviorAdaptiveStrike:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("water_adaptive_strike")   
	local target
	local desire = 0

	if AICore.currentBehavior == self then return desire end

	if self.strikeAbility and self.strikeAbility:IsFullyCastable() then
		local range = self.strikeAbility:GetCastRange()
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

function BehaviorAdaptiveStrike:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = self.target:entindex(),
		AbilityIndex = self.strikeAbility:entindex()
	}
end 

BehaviorAdaptiveStrike.Continue = BehaviorAdaptiveStrike.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorAdaptiveStrike:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone ,BehaviorWishFuse,BehaviorFusing,BehaviorThrowHook,BehaviorDismember,BehaviorAdaptiveStrike}

