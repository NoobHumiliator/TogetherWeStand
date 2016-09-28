--[[
光球的AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( {BehaviorRun} ) 
end

function AIThink() 
    if thisEntity:IsNull() or not thisEntity:IsAlive() then
		return nil
	end
	return behaviorSystem:Think()
end

---------------------------------------------------------------------------------------------------------
POSITIONS_retreat = Entities:FindAllByName( "*waypoint*" )
for i = 1, #POSITIONS_retreat do
	POSITIONS_retreat[i] = POSITIONS_retreat[i]:GetOrigin()
end
-------------------------------------------------------------------------------------------------------------
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


