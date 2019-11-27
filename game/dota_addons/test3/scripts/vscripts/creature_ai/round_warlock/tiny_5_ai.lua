--[[1形态的小小AI
]]
require("ai_core")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn(entityKeyValues)
    thisEntity:SetContextThink("AIThink", AIThink, 0.25)
    behaviorSystem = AICore:CreateBehaviorSystem({ BehaviorNone, BehaviorHold, BehaviorFreeze, BehaviorStrike, BehaviorStatic_Link, BehaviorEvolve })
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
BehaviorStrike = {}

function BehaviorStrike:Evaluate()
    self.strikeAbility = thisEntity:FindAbilityByName("tiny_avalance")    --对技能进行定义
    local target
    local desire = 0

    -- let's not choose this twice in a row
    if AICore.currentBehavior == self then return desire end

    if self.strikeAbility and self.strikeAbility:IsFullyCastable() then   --技能存在而且处于CD中有蓝
        local range = self.strikeAbility:GetCastRange()
        target = AICore:RandomBadEnemyInRange(thisEntity, range)
    end

    if target then
        desire = 4
        self.target = target
        local targetPoint = self.target:GetOrigin() + RandomVector(20)
        self.point = targetPoint
        print("light")
    else
        desire = 0
    end

    return desire
end

function BehaviorStrike:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        AbilityIndex = self.strikeAbility:entindex(),
        Position = self.point
    }
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

function BehaviorStrike:Think(dt)
    if not self.target:IsAlive() then
        self.endTime = GameRules:GetGameTime()
        return
    end
end
--------------------------------------------------------------------------------------------------------
BehaviorEvolve = {}                --------------觉醒
function BehaviorEvolve:Evaluate()
    local desire = 1
    if currentBehavior == self then return desire end
    self.plasmaAbility = thisEntity:FindAbilityByName("tiny_wake")
    if thisEntity:GetHealth() > 52500 and self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
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
BehaviorStatic_Link = {}

function BehaviorStatic_Link:Evaluate()
    -- let's not choose this twice in a row
    if AICore.currentBehavior == self then return desire end
    self.staticlinkAbility = thisEntity:FindAbilityByName("tiny_splitter")    --对技能进行定义
    local desire = 0
    local range = self.staticlinkAbility:GetCastRange()
    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    local minHP = nil
    local target = nil

    for _, enemy in pairs(enemies) do
        local HP = enemy:GetHealth()
        if enemy:IsAlive() and (minHP == nil or HP < minHP) then
            minHP = HP
            target = enemy
        end
    end
    local tosstarget = nil
    tosstarget = AICore:RandomBadEnemyInRange(thisEntity, 350)



    if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() and target and tosstarget then   --当前生命值小于最大生命值除以2
        desire = 7
        self.target = target
        local targetPoint = self.target:GetOrigin() + RandomVector(20)
        self.point = targetPoint
        self.order =         {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            AbilityIndex = self.staticlinkAbility:entindex(),
            Position = self.point
        }
    else
        desire = 1
    end

    return desire
end

function BehaviorStatic_Link:Begin()
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

BehaviorStatic_Link.Continue = BehaviorStatic_Link.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorStatic_Link:Think(dt)
    if not self.target:IsAlive() then
        self.endTime = GameRules:GetGameTime()
        return
    end
end
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone, BehaviorHold, BehaviorFreeze, BehaviorStrike, BehaviorStatic_Link, BehaviorEvolve }