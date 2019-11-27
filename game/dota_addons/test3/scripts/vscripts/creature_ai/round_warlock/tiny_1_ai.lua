--[[1形态的小小AI
]]
require("ai_core")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn(entityKeyValues)
    thisEntity:SetContextThink("AIThink", AIThink, 0.25)
    behaviorSystem = AICore:CreateBehaviorSystem({ BehaviorNone, BehaviorHold, BehaviorFreeze, BehaviorEvolve })
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
    return behaviorSystem:Think()
end

function CollectRetreatMarkers()
    local result = {}
    local i = 1
    local wp = nil
    while true do
        wp = Entities:FindByName(nil, string.format("waypoint_middle%d", i))
        if not wp then
            return result
        end
        table.insert(result, wp:GetOrigin())
        i = i + 1
    end
end
POSITIONS_retreat = CollectRetreatMarkers()
--------------------------------------------------------------------------------------------------------
BehaviorNone = {}
function BehaviorNone:Evaluate()
    local j = 1
    local desire = 1
    local minDistance = 10000000
    while POSITIONS_retreat[j] do
        local distance = (thisEntity:GetOrigin() - POSITIONS_retreat[j]):Length()
        if distance < minDistance then   --距离中心距离超过1000
            minDistance = distance
            self.happytogo = POSITIONS_retreat[j]
        end
        j = j + 1
    end
    if minDistance > 2000 then
        desire = 3
    end
    return desire -- must return a value > 0, so we have a default 控制大方向，往地图中央处靠
end

function BehaviorNone:Begin()
    self.endTime = GameRules:GetGameTime() + 1

    for i = 0, DOTA_ITEM_MAX - 1 do
        local item = thisEntity:GetItemInSlot(i)
        if item and item:GetAbilityName() == "item_force_staff" then
            self.forceAbility = item
        end
    end


    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = self.happytogo
    }
end

BehaviorNone.Continue = BehaviorNone.Begin
-------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
BehaviorHold = {}                --------------保持在地图中央的位置

function BehaviorHold:Evaluate()
    local desire = 1
    -- let's not choose this twice in a row
    local j = 1
    local target
    self.plasmaAbility = thisEntity:FindAbilityByName("water_grow")
    while POSITIONS_retreat[j] do
        local distance = (thisEntity:GetOrigin() - POSITIONS_retreat[j]):Length()
        if distance < 2000 then   --距离其中一个不超过300
            desire = 2
        end
        j = j + 1
    end
    return desire
end

function BehaviorHold:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        DOTA_UNIT_ORDER_HOLD_POSITION
    }

end

BehaviorHold.Continue = BehaviorHold.Begin
--------------------------------------------------------------------------------------------------------
BehaviorFreeze = {}         ----------------------------------------------------------崩坏

function BehaviorFreeze:Evaluate()
    local desire = 1
    -- let's not choose this twice in a row
    if currentBehavior == self then return desire end
    self.freezeAbility = thisEntity:FindAbilityByName("tiny_collapse")
    if self.freezeAbility and self.freezeAbility:IsFullyCastable() then
        desire = 11
    end
    return desire
end

function BehaviorFreeze:Begin()
    self.endTime = GameRules:GetGameTime() + 1.2
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = self.freezeAbility:entindex()
    }

end

BehaviorFreeze.Continue = BehaviorFreeze.Begin
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
BehaviorEvolve = {}                --------------进化
function BehaviorEvolve:Evaluate()
    local desire = 1
    if currentBehavior == self then return desire end
    self.plasmaAbility = thisEntity:FindAbilityByName("tiny_growto_2")
    if thisEntity:GetHealth() > 4500 and self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
        desire = 15
    end
    return desire
end
function BehaviorEvolve:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = self.plasmaAbility:entindex()
    }
end
BehaviorEvolve.Continue = BehaviorEvolve.Begin
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone, BehaviorHold, BehaviorFreeze, BehaviorEvolve }