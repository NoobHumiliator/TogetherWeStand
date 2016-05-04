--[[
最基本的追着人打的AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone ,BehaviorStatic_Link} ) 
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
--------------------------------------------------------------------------------------------------------
BehaviorStatic_Link = {}
function BehaviorStatic_Link:Evaluate()
	-- let's not choose this twice in a row
	local desire = 0
	if AICore.currentBehavior == self then return desire end
	self.staticlinkAbility = thisEntity:FindAbilityByName("invoker_metor_holdout")    --对技能进行定义
	local range = self.staticlinkAbility:GetCastRange()

    local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin() , nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, 0, false)
	local MinDistance = 10000
    if #targets > 0 then
       for i,unit in pairs(targets) do                            
           local distance = ( thisEntity:GetOrigin() - unit:GetOrigin() ):Length()
             if distance < MinDistance and self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() then
				     MinDistance=distance
                     self.target=unit
                     desire=6
             end
       end
    end   	
	return desire
end

function BehaviorStatic_Link:Begin()
	 local targetPoint = self.target:GetOrigin()
	 self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.staticlinkAbility:entindex(),
		Position = targetPoint
	}
	self.endTime = GameRules:GetGameTime() + 1
end 

BehaviorStatic_Link.Continue = BehaviorStatic_Link.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone ,BehaviorStatic_Link}

