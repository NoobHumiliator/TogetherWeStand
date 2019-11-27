--[[
育母蜘蛛
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone} )
      thisEntity:AddNewModifier(nil,nil,"modifier_kill",{duration=120})  --设置强制死亡时间
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

function BehaviorNone:Think(dt)
    if not thisEntity:IsAlive() then
		return nil
	end
    ABILITY_spawn_spider = thisEntity:FindAbilityByName( "creature_spawn_spider" )
	-- Spawn a broodmother whenever we're able to do so.
	if ABILITY_spawn_spider:IsFullyCastable() then
		thisEntity:CastAbilityImmediately( ABILITY_spawn_spider, -1 )
		return 1.0
	end
	return 0.25 + RandomFloat( 0.25, 0.5 )
end
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone}