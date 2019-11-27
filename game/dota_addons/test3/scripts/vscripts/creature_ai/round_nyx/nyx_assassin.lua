require("ai_core")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn(entityKeyValues)
    if thisEntity:GetTeam() == DOTA_TEAM_BADGUYS then
        thisEntity:SetContextThink("AIThink", AIThink, 0.25)
        behaviorSystem = AICore:CreateBehaviorSystem({ BehaviorNone, BehaviorThrowHook })
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
    self.target = nil
    local allEnemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    if #allEnemies > 0 then
        self.target = allEnemies[1]
    end

    if self.target and self.target:IsAlive() then
        self.order = {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = self.target:GetOrigin()
        }
    else
        self.order = {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        }
    end
end

BehaviorNone.Continue = BehaviorNone.Begin
--------------------------------------------------------------------------------------------------------
BehaviorThrowHook = {}
function BehaviorThrowHook:Evaluate()
    local desire = 1
    -- let's not choose this twice in a row
    if currentBehavior == self then return desire end
    self.hookAbility = thisEntity:FindAbilityByName("creature_nyx_assassin_impale")
    local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_FARTHEST, false)

    if #targets > 0 and self.hookAbility and self.hookAbility:IsFullyCastable() then
        self.target = targets[1]
		desire = 5
    end
    return desire
end

function BehaviorThrowHook:Begin()
    self.endTime = GameRules:GetGameTime() + 1

    local targetPoint = self.target:GetOrigin() + RandomVector(50)

    self.order = {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        AbilityIndex = self.hookAbility:entindex(),
        Position = targetPoint
    }
end
BehaviorThrowHook.Continue = BehaviorThrowHook.Begin
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone, BehaviorThrowHook }