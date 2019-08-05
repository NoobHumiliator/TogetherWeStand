--[[猛犸BOSS的AI
]]
require("ai_core")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn(entityKeyValues)
    if IsServer() and thisEntity:GetTeam() == DOTA_TEAM_BADGUYS then
        thisEntity:SetContextThink("AIThink", AIThink, 0.25)
        behaviorSystem = AICore:CreateBehaviorSystem({ BehaviorNone, BehaviorGreat_Gush, BehaviorCurrent_Storm, BehaviorStatic_Link })
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


    if self.target then
        self.order =         {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
            Position = self.target:GetOrigin()
        }
    else
        self.order =         {
            UnitIndex = thisEntity:entindex(),
            OrderType = DOTA_UNIT_ORDER_STOP
        }
    end
end

BehaviorNone.Continue = BehaviorNone.Begin
--------------------------------------------------------------------------------------------------------
BehaviorGreat_Gush = {}

function BehaviorGreat_Gush:Evaluate()
    local desire = 0

    -- let's not choose this twice in a row
    if currentBehavior == self then return desire end

    self.gushAbility = thisEntity:FindAbilityByName("boss_great_gush")

    if self.gushAbility and self.gushAbility:IsFullyCastable() then
        self.target = AICore:RandomEnemyHeroInRangeIgnoreImmnue(thisEntity, 550)
        if self.target then
            desire = 6
        end
    end
    return desire
end

function BehaviorGreat_Gush:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = self.gushAbility:entindex()
    }

end
BehaviorGreat_Gush.Continue = BehaviorGreat_Gush.Begin
--------------------------------------------------------------------------------------------------------
BehaviorCurrent_Storm = {}

function BehaviorCurrent_Storm:Evaluate()
    local desire = 0

    -- let's not choose this twice in a row
    if currentBehavior == self then return desire end

    self.stormAbility = thisEntity:FindAbilityByName("boss_current_storm")

    if self.stormAbility and self.stormAbility:IsFullyCastable() then
        self.target = AICore:RandomEnemyHeroInRangeIgnoreImmnue(thisEntity, 550)
        if self.target then
            desire = 7
        end
    end
    return desire
end

function BehaviorCurrent_Storm:Begin()
    self.endTime = GameRules:GetGameTime() + 1
    self.order =     {
        UnitIndex = thisEntity:entindex(),
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        AbilityIndex = self.stormAbility:entindex()
    }

end
BehaviorCurrent_Storm.Continue = BehaviorCurrent_Storm.Begin
--------------------------------------------------------------------------------------------------------
BehaviorStatic_Link = {}

function BehaviorStatic_Link:Evaluate()

    self.staticlinkAbility = thisEntity:FindAbilityByName("boss_suffocating_bubble")
    local target = nil
    local desire = 0
    -- let's not choose this twice in a row
    if AICore.currentBehavior == self then return desire end

    if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() then
        local range = self.staticlinkAbility:GetCastRange()
        target = AICore:RandomEnemyHeroInRangeIgnoreImmnue(thisEntity, range)
    end

    if target then
        desire = 8
        self.target = target
        self.order =         {
            OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
            UnitIndex = thisEntity:entindex(),
            TargetIndex = target:entindex(),
            AbilityIndex = self.staticlinkAbility:entindex()
        }
    else
        desire = 1
    end

    return desire
end

function BehaviorStatic_Link:Begin()
    self.endTime = GameRules:GetGameTime() + 1
end
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone, BehaviorGreat_Gush, BehaviorCurrent_Storm, BehaviorStatic_Link }