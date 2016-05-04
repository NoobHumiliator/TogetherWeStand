--[[
Male Sipder AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
	behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorLaunchMissile, BehaviorRun } )
	thisEntity:AddNewModifier(nil,nil,"modifier_kill",{duration=500})  --设置强制死亡时间
end

function AIThink()
	if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil -- deactivate this think function
	end
	return behaviorSystem:Think()
end

--------------------------------------------------------------------------------------------------------

POSITIONS_retreat = Entities:FindAllByName( "malewaypoint_*" )
for i = 1, #POSITIONS_retreat do
	POSITIONS_retreat[i] = POSITIONS_retreat[i]:GetOrigin()
end

BehaviorRun =
{
	order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
		Position = POSITIONS_retreat[ RandomInt(1, #POSITIONS_retreat) ],
	}
}

function BehaviorRun:Evaluate()
	return 1 -- must return a value > 0, so we have a default
end

function BehaviorRun:Initialize()
end

function BehaviorRun:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorRun:Continue()
	self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorRun:Think(dt)
	local currentPos = thisEntity:GetOrigin()
	currentPos.z = 0

	if ( self.order.Position - currentPos ):Length() < 500 then
		self.order.Position = POSITIONS_retreat[ RandomInt(1, #POSITIONS_retreat) ]
	end
end

--------------------------------------------------------------------------------------------------------

BehaviorLaunchMissile = {}

function BehaviorLaunchMissile:Evaluate()
	self.ability = thisEntity:FindAbilityByName("creature_spawn_baneling")
    desire=0
	if self.ability and self.ability:IsFullyCastable() then
        desire = 5
		self.order =
		{
            OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		    UnitIndex = thisEntity:entindex(),	
			AbilityIndex = self.ability:entindex()
		}
	end
	return desire
end

function BehaviorLaunchMissile:Begin()
	self.endTime = GameRules:GetGameTime() + 2.0
end

BehaviorLaunchMissile.Continue = BehaviorLaunchMissile.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorLaunchMissile:Think(dt)
	if not self.ability:IsFullyCastable() and not self.ability:IsInAbilityPhase() then
		self.endTime = GameRules:GetGameTime()
	end
end
