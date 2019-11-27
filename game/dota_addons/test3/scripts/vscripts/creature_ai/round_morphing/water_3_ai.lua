--[[收割形态的水人AI
]]
require("ai_core")

behaviorSystem = {} -- create the global so we can assign to it

initFlag = false   --是否成功初始化的标志位

function Spawn(entityKeyValues)
    if thisEntity:GetTeam() == DOTA_TEAM_BADGUYS then
        thisEntity:SetContextThink("AIThink", AIThink, 0.25)
        behaviorSystem = AICore:CreateBehaviorSystem({ BehaviorNone, BehaviorWishFuse, BehaviorFusing, BehaviorThrowHook, BehaviorDismember })
    end
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
    if not initFlag then
        thisEntity:FindAbilityByName("water_fuse"):SetLevel(1)
        thisEntity:FindAbilityByName("water_torrent"):SetLevel(1)
        thisEntity:FindAbilityByName("water_waveform"):SetLevel(1)
        initFlag = true
    end
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
        self.order =        {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = self.target:GetOrigin()
        }
    else
        self.order =        {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        }
    end
end

BehaviorNone.Continue = BehaviorNone.Begin
--------------------------------------------------------------------------------------------------------
BehaviorWishFuse = {}
function BehaviorWishFuse:Evaluate()
    local desire = 1
    local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)

    for _, unit in pairs(targets) do
        if unit:GetUnitName() == "npc_majia_water_1" then
            self.target = unit
            desire = 9
            break
        end
    end
    return desire
end
function BehaviorWishFuse:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    if self.target and self.target:IsAlive() then
        self.order =        {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = self.target:GetOrigin()
        }
    else
        self.order =        {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        }
    end
end

BehaviorWishFuse.Continue = BehaviorWishFuse.Begin

function BehaviorWishFuse:Think(dt)
    if not self.target:IsAlive() then
        self.endTime = GameRules:GetGameTime()
        return
    end
end
--------------------------------------------------------------------------------------------------------
BehaviorFusing = {}
function BehaviorFusing:Evaluate()
    local desire = 1
    if currentBehavior == self then return desire end

    self.plasmaAbility = thisEntity:FindAbilityByName("water_fuse")
    if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
    local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
        for _, unit in pairs(targets) do
            if unit:GetUnitName() == "npc_majia_water_1" then
                desire = 10
                break
            end
        end
    end
    return desire
end
function BehaviorFusing:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =    {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = self.plasmaAbility:entindex()
    }
end

BehaviorFusing.Continue = BehaviorFusing.Begin
--------------------------------------------------------------------------------------------------------
BehaviorThrowHook = {}

function BehaviorThrowHook:Evaluate()
    local desire = 1

    -- let's not choose this twice in a row
    if currentBehavior == self then return desire end
    self.hookAbility = thisEntity:FindAbilityByName("water_waveform")
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

    self.order =    {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        AbilityIndex = self.hookAbility:entindex(),
        Position = targetPoint
    }

end

BehaviorThrowHook.Continue = BehaviorThrowHook.Begin
--------------------------------------------------------------------------------------------------------
BehaviorDismember = {}          ------------------洪流

function BehaviorDismember:Evaluate()
    self.dismemberAbility = thisEntity:FindAbilityByName("water_torrent")
    local target
    local desire = 0

    -- let's not choose this twice in a row
    if AICore.currentBehavior == self then return desire end

    if self.dismemberAbility and self.dismemberAbility:IsFullyCastable() then
        local range = self.dismemberAbility:GetCastRange()
        target = AICore:RandomEnemyHeroInRange(thisEntity, range)
    end

    if target then
        desire = 4
        self.target = target
    else
        desire = 1
    end

    return desire
end

function BehaviorDismember:Begin()
    local targetPoint = self.target:GetOrigin() + RandomVector(50)
    self.endTime = GameRules:GetGameTime() + 1

    self.order =    {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
        AbilityIndex = self.dismemberAbility:entindex(),
        Position = targetPoint
    }
end

BehaviorDismember.Continue = BehaviorDismember.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorDismember:Think(dt)
    if not self.target:IsAlive() then
        self.endTime = GameRules:GetGameTime()
        return
    end
end
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone, BehaviorWishFuse, BehaviorFusing, BehaviorThrowHook, BehaviorDismember }