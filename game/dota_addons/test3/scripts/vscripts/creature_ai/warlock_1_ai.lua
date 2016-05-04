--[[
1形态的小小AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorThrowHook , BehaviorLight_Strike ,BehaviorDismember,BehaviorFreeze } ) 
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

function CollectRetreatMarkers()
	local result = {}
	local i = 1
	local wp = nil
	while true do
		wp = Entities:FindByName( nil, string.format("waypoint_middle%d", i ) )
		if not wp then
			return result
		end
		table.insert( result, wp:GetOrigin() )
		i = i + 1
	end
end
POSITIONS_retreat = CollectRetreatMarkers()
--------------------------------------------------------------------------------------------------------
hTarget = nil
BehaviorNone = {}
function BehaviorNone:Evaluate()
	return 2 -- must return a value > 0, so we have a default 控制大方向，往一个最近的英雄处靠近
end

function BehaviorNone:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
		if #allEnemies > 0 then
			local minDistance = 10000000
			for _,enemy in pairs(allEnemies) do
				local distance = ( thisEntity:GetOrigin() - enemy:GetOrigin() ):Length()
				if distance < minDistance then
				  minDistance=distance
                  hTarget=enemy
				end
			end
		end


	if hTarget and hTarget:IsAlive() then
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
			Position =  hTarget:GetOrigin()
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
BehaviorThrowHook = {}

function BehaviorThrowHook:Evaluate()       ------飞过去开大
	local desire = 0
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.hookAbility = thisEntity:FindAbilityByName( "fire_to_point" )
	if self.hookAbility and self.hookAbility:IsFullyCastable() and ( thisEntity:GetOrigin() - POSITIONS_retreat[ RandomInt(1, #POSITIONS_retreat) ] ):Length()>800 then
			desire = 15     
		else
			desire = 1
	end	
	return desire
end

function BehaviorThrowHook:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.hookAbility:entindex(),
		Position = POSITIONS_retreat[ RandomInt(1, #POSITIONS_retreat) ]
	}

end

BehaviorThrowHook.Continue = BehaviorThrowHook.Begin
-------------------------------------------------------------------------------------------------------
BehaviorLight_Strike = {}

function BehaviorLight_Strike:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("drag_away")    --拖走
	local target
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	 local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
        if #targets > 0 then
           for i,unit in pairs(targets) do                 
               if unit:GetUnitName()==("npc_dota_tiny_1") or unit:GetUnitName()==("npc_dota_tiny_2") or unit:GetUnitName()==("npc_dota_tiny_3") or unit:GetUnitName()==("npc_dota_tiny_4") or unit:GetUnitName()==("npc_dota_tiny_5") then     
                   target=unit
               end 
           end
       end     

	if target and self.strikeAbility and self.strikeAbility:IsFullyCastable() then
		desire = 16
		self.target = target
       local targetPoint = self.target:GetOrigin()	
	else
		desire = 1
	end

	return desire
end

function BehaviorLight_Strike:Begin()
	self.endTime = GameRules:GetGameTime() + 0.5
	--[[self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
        TargetIndex = self.target:entindex(),
		AbilityIndex = self.staticlinkAbility:entindex()
	}
    --]]
    self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = self.strikeAbility:entindex(),
		TargetIndex = self.target:entindex()
	}
end 

BehaviorLight_Strike.Continue = BehaviorLight_Strike.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorLight_Strike:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
BehaviorDismember = {}

function BehaviorDismember:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("shackle_element")    --拖走
	local target
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	 local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
        if #targets > 0 then
           for i,unit in pairs(targets) do                 
               if unit:GetUnitName()==("npc_dota_tiny_1") or unit:GetUnitName()==("npc_dota_tiny_2") or unit:GetUnitName()==("npc_dota_tiny_3") or unit:GetUnitName()==("npc_dota_tiny_4") or unit:GetUnitName()==("npc_dota_tiny_5") then     
                   target=unit
               end 
           end
       end     

	if target and self.strikeAbility and self.strikeAbility:IsFullyCastable() then
		desire = 14
		self.target = target
       local targetPoint = self.target:GetOrigin()	
	else
		desire = 1
	end

	return desire
end

function BehaviorDismember:Begin()
	self.endTime = GameRules:GetGameTime() + 20

	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = self.target:entindex(),
		AbilityIndex = self.strikeAbility:entindex()
	}
end
BehaviorDismember.Continue = BehaviorDismember.Begin  --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorDismember:Think(dt)
	if (not self.target:IsAlive())or thisEntity:GetHealth()<(thisEntity:GetMaxHealth()*0.75) then
		self.endTime = GameRules:GetGameTime()
		return
	end
end

--------------------------------------------------------------------------------------------------------
BehaviorFreeze = {}         ----------------------------------------------------------消失

function BehaviorFreeze:Evaluate()
	local desire = 1
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end
	self.freezeAbility = thisEntity:FindAbilityByName( "warlock_disappear" )
	if self.freezeAbility and self.freezeAbility:IsFullyCastable() and thisEntity:GetHealth()<(thisEntity:GetMaxHealth()*0.75) then
			desire = 20
	end	
	return desire
end

function BehaviorFreeze:Begin()
	self.endTime = GameRules:GetGameTime() + 1.2	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.freezeAbility:entindex()
	}

end

BehaviorFreeze.Continue = BehaviorFreeze.Begin
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorThrowHook , BehaviorLight_Strike ,BehaviorDismember,BehaviorFreeze}

