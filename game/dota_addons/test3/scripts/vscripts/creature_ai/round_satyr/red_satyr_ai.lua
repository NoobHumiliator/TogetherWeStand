--[[
最基本的追着人打的AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorStatic_Link} )
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
--------------------------------------------------------------------------------------------------------
BehaviorStatic_Link = {}
function BehaviorStatic_Link:Evaluate()
	-- let's not choose this twice in a row
	local desire = 0
	local target=nil
	if AICore.currentBehavior == self then return desire end
	self.staticlinkAbility = thisEntity:FindAbilityByName("creature_aoe_spikes")    --对技能进行定义
	local range = self.staticlinkAbility:GetCastRange()

    if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() then   --技能存在而且处于CD中有蓝
		local range = self.staticlinkAbility:GetCastRange()
		target = AICore:RandomEnemyInRange( thisEntity, range )
	end

	if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() and target then
		desire = 7
		self.target = target
        local targetPoint = self.target:GetOrigin()

	    self.order =
	    {
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.staticlinkAbility:entindex(),
		Position = targetPoint
	    }
	else
		desire = 1
	end

	return desire
end

function BehaviorStatic_Link:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

BehaviorStatic_Link.Continue = BehaviorStatic_Link.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorStatic_Link}

