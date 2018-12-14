--[[
2形态的warlock
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorLight_Strike ,BehaviorStrike,BehaviorLight } ) 
      thisEntity:AddNewModifier(nil,nil,"modifier_kill",{duration=150})  --设置强制死亡时间
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


	if hTarget then 
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
-------------------------------------------------------------------------------------------------------
BehaviorLight_Strike = {}

function BehaviorLight_Strike:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("drag_away")    --拖走
	local target
	local desire = 1

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

--------------------------------------------------------------------------------------------------------
BehaviorStrike = {}

function BehaviorStrike:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("rain_chaos")    --对技能进行定义
	local target
	local desire = 1

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.strikeAbility and self.strikeAbility:IsFullyCastable() then   --技能存在而且处于CD中有蓝
		local range = self.strikeAbility:GetCastRange()
		target = AICore:RandomEnemyHeroInRange( thisEntity, range )
	end

	if target then
		desire = 4
		self.target = target
       local targetPoint = self.target:GetOrigin()
	
    print("light")
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.strikeAbility:entindex(),
		Position = targetPoint
	}
	else
		desire = 1
	end

	return desire
end

function BehaviorStrike:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	--[[self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
        TargetIndex = self.target:entindex(),
		AbilityIndex = self.staticlinkAbility:entindex()
	}
    --]]
end 

BehaviorStrike.Continue = BehaviorStrike.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

--------------------------------------------------------------------------------------------------------
BehaviorLight = {}

function BehaviorLight:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("fatal_bonds")    --对技能进行定义
	local target
	local desire = 1

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.strikeAbility and self.strikeAbility:IsFullyCastable() then   --技能存在而且处于CD中有蓝
		local range = self.strikeAbility:GetCastRange()
		target = AICore:RandomEnemyHeroInRange( thisEntity, range )
	end

	if target then
		desire = 6
		self.target = target
       local targetPoint = self.target:GetOrigin()	
	else
		desire = 1
	end

	return desire
end

function BehaviorLight:Begin()
	self.endTime = GameRules:GetGameTime() + 1
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

BehaviorLight.Continue = BehaviorLight.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorLight_Strike ,BehaviorStrike,BehaviorLight}

