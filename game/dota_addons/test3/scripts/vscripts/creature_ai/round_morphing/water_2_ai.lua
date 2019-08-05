--[[2形态的水人AI
]]
require("ai_core")

behaviorSystem = {} -- create the global so we can assign to it

initFlag = false   --是否成功初始化的标志位

function Spawn(entityKeyValues)
    if thisEntity:GetTeam() == DOTA_TEAM_BADGUYS then
        thisEntity:SetContextThink("AIThink", AIThink, 0.25)
        behaviorSystem = AICore:CreateBehaviorSystem({ BehaviorNone, BehaviorWishFuse, BehaviorFusing, BehaviorThrowHook, BehaviorDismember, BehaviorPlasma_Field, BehaviorHold, BehaviorEvolve })
    end
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
    if not initFlag then
        thisEntity:FindAbilityByName("water_grow"):SetLevel(1)
        thisEntity:FindAbilityByName("water_fuse"):SetLevel(1)
        thisEntity:FindAbilityByName("water_torrent"):SetLevel(1)
        initFlag = true
    end
    return behaviorSystem:Think()
end

function CollectRetreatMarkers()
    local result = {}
    local i = 1
    local wp = nil
    while true do
        wp = Entities:FindByName(nil, string.format("waypoint_water%d", i))
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
        if distance < minDistance then   --距离三个水池距离超过300
            minDistance = distance
            self.happytogo = POSITIONS_retreat[j]
        end
        j = j + 1
    end
    if minDistance > 500 then
        desire = 3
    end
    return desire -- must return a value > 0, so we have a default 控制大方向，往最近的水池子处靠
end

function BehaviorNone:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
        Position = self.happytogo
    }
end

BehaviorNone.Continue = BehaviorNone.Begin
-------------------------------------------------------------------------------------------------------
BehaviorPlasma_Field = {}                --------------成长

function BehaviorPlasma_Field:Evaluate()
    local desire = 1
    -- let's not choose this twice in a row
    local j = 1
    self.plasmaAbility = thisEntity:FindAbilityByName("water_grow")
    while POSITIONS_retreat[j] do
        local distance = (thisEntity:GetOrigin() - POSITIONS_retreat[j]):Length()
        if distance < 510 and self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then   --距离其中一个不超过500,并且成长这个技能CD好了
            desire = 4
        end
        j = j + 1
    end
    return desire
end

function BehaviorPlasma_Field:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = self.plasmaAbility:entindex()
    }

end

BehaviorPlasma_Field.Continue = BehaviorPlasma_Field.Begin
--------------------------------------------------------------------------------------------------------
BehaviorHold = {}                --------------保持在池子里的位置

function BehaviorHold:Evaluate()
    local desire = 1
    -- let's not choose this twice in a row
    local j = 1
    local target
    self.plasmaAbility = thisEntity:FindAbilityByName("water_grow")
    while POSITIONS_retreat[j] do
        local distance = (thisEntity:GetOrigin() - POSITIONS_retreat[j]):Length()
        if distance < 500 then   --距离其中一个不超过500
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
BehaviorWishFuse = {}              ------------------------往融合位置靠
function BehaviorWishFuse:Evaluate()
    local desire = 1
    local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 700, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_CLOSEST, false)

    for _, unit in pairs(targets) do
        if unit:GetUnitName() == ("npc_majia_water_1") then
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
        self.order =         {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = self.target:GetOrigin()
        }
    else
        self.order =         {
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
BehaviorFusing = {}                --------------融合
function BehaviorFusing:Evaluate()
    local desire = 1
    if currentBehavior == self then return desire end

    self.plasmaAbility = thisEntity:FindAbilityByName("water_fuse")
    local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
        for _, unit in pairs(targets) do
            if unit:GetUnitName() == ("npc_majia_water_1") then
                desire = 10
                break
            end
        end
    end
    return desire
end
function BehaviorFusing:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = self.plasmaAbility:entindex()
    }
end

BehaviorFusing.Continue = BehaviorFusing.Begin
--------------------------------------------------------------------------------------------------------
BehaviorEvolve = {}                --------------进化
function BehaviorEvolve:Evaluate()
    local desire = 1
    local flDHPadjust = GameRules:GetGameModeEntity().CHoldoutGameMode.flDHPadjust

    if currentBehavior == self then return desire end
    self.plasmaAbility = thisEntity:FindAbilityByName("water_evolve_to_3")
    if thisEntity:GetMaxHealth() > 5000 * flDHPadjust and self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
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
BehaviorDismember = {}          ------------------洪流

function BehaviorDismember:Evaluate()
    self.dismemberAbility = thisEntity:FindAbilityByName("holdout_current")
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

    self.order =     {
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
AICore.possibleBehaviors = { BehaviorNone, BehaviorWishFuse, BehaviorFusing, BehaviorThrowHook, BehaviorDismember, BehaviorPlasma_Field, BehaviorHold, BehaviorEvolve }
