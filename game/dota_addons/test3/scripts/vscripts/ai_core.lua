--[[Tower Defense AI

These are the valid orders, in case you want to use them (easier here than to find them in the C code):

DOTA_UNIT_ORDER_NONE	                0
DOTA_UNIT_ORDER_MOVE_TO_POSITION	    1
DOTA_UNIT_ORDER_MOVE_TO_TARGET	        2
DOTA_UNIT_ORDER_ATTACK_MOVE	            3
DOTA_UNIT_ORDER_ATTACK_TARGET	        4
DOTA_UNIT_ORDER_CAST_POSITION	        5
DOTA_UNIT_ORDER_CAST_TARGET	            6
DOTA_UNIT_ORDER_CAST_TARGET_TREE	    7
DOTA_UNIT_ORDER_CAST_NO_TARGET	        8
DOTA_UNIT_ORDER_CAST_TOGGLE	            9
DOTA_UNIT_ORDER_HOLD_POSITION	        10
DOTA_UNIT_ORDER_TRAIN_ABILITY	        11
DOTA_UNIT_ORDER_DROP_ITEM	            12
DOTA_UNIT_ORDER_GIVE_ITEM	            13
DOTA_UNIT_ORDER_PICKUP_ITEM	            14
DOTA_UNIT_ORDER_PICKUP_RUNE	            15
DOTA_UNIT_ORDER_PURCHASE_ITEM	        16
DOTA_UNIT_ORDER_SELL_ITEM	            17
DOTA_UNIT_ORDER_DISASSEMBLE_ITEM	    18
DOTA_UNIT_ORDER_MOVE_ITEM	            19
DOTA_UNIT_ORDER_CAST_TOGGLE_AUTO	    20
DOTA_UNIT_ORDER_STOP	                21
DOTA_UNIT_ORDER_TAUNT	                22
DOTA_UNIT_ORDER_BUYBACK	                23
DOTA_UNIT_ORDER_GLYPH	                24
DOTA_UNIT_ORDER_EJECT_ITEM_FROM_STASH	25
DOTA_UNIT_ORDER_CAST_RUNE	            26
]]
AICore = {}

function AICore:RandomNormalFriendCreepInRange(entity, range)  --选一个范围内非英雄的普通单位 死亡契约
    local creeps = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, FIND_ANY_ORDER, false)
    if #creeps > 0 then
        local index = RandomInt(1, #creeps)
        return creeps[index]
    else
        return nil
    end
end

function AICore:ClosestEnemyHeroInRange(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NO_INVIS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end


function AICore:RandomEnemyHeroInRange(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end


function AICore:RandomEnemyHeroInRangeIgnoreImmnue(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end



function AICore:RandomEnemyHeroInRangeNotIllusion(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end

function AICore:RandomEnemyInRange(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end




function AICore:RandomEnemyHeroInRangeNotIllusionIgnoreImmnue(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end



function AICore:RandomBadEnemyInRange(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end


function AICore:RandomBadHeroInRange(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end

function AICore:WeakestEnemyHeroInRange(entity, range)
    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)

    local minHP = nil
    local target = nil

    for _, enemy in pairs(enemies) do
        local distanceToEnemy = (entity:GetOrigin() - enemy:GetOrigin()):Length()
        local HP = enemy:GetHealth()
        if enemy:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
            minHP = HP
            target = enemy
        end
    end

    return target
end

function AICore:WeakestAllyHeroInRange(entity, range)
    local allies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, entity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false)
    local minHP = nil
    local target = nil
    for _, ally in pairs(allies) do
        local HP = ally:GetHealth()
        if ally:IsAlive() and (minHP == nil or HP < minHP) then
            minHP = HP
            target = ally
        end
    end

    return target
end


function AICore:CreateBehaviorSystem(behaviors)
    local BehaviorSystem = {}

    BehaviorSystem.possibleBehaviors = behaviors
    BehaviorSystem.thinkDuration = 0.5
    BehaviorSystem.repeatedlyIssueOrders = true -- if you're paranoid about dropped orders, leave this true

    BehaviorSystem.currentBehavior =    {
        endTime = 0,
        order = { OrderType = DOTA_UNIT_ORDER_NONE }
    }

    function BehaviorSystem:Think()
        if GameRules:GetGameTime() >= self.currentBehavior.endTime then
            local newBehavior = self:ChooseNextBehavior()
            if newBehavior == nil then
                -- Do nothing here... this covers possible problems with ChooseNextBehavior
            elseif newBehavior == self.currentBehavior and self.currentBehavior.Continue then
                self.currentBehavior:Continue()
            else
                if self.currentBehavior.End then self.currentBehavior:End() end
                self.currentBehavior = newBehavior
                self.currentBehavior:Begin()
            end
        end

        if self.currentBehavior.order and self.currentBehavior.order.OrderType ~= DOTA_UNIT_ORDER_NONE then
            if self.repeatedlyIssueOrders or self.previousOrderType ~= self.currentBehavior.order.OrderType or
            self.previousOrderTarget ~= self.currentBehavior.order.TargetIndex or
            self.previousOrderPosition ~= self.currentBehavior.order.Position then

                if self.previousOrderType == DOTA_UNIT_ORDER_ATTACK_MOVE and   --如果新旧两次均为攻击指令,并且相距位置不超过200，则无需发送新指令，避免指令频繁打断上次的动作
                self.currentBehavior.order.OrderType == DOTA_UNIT_ORDER_ATTACK_MOVE and
                (self.previousOrderPosition - self.currentBehavior.order.Position):Length2D() < 200 then
                else
                    -- Keep sending the order repeatedly, in case we forgot >.<
                    ExecuteOrderFromTable(self.currentBehavior.order)
                    self.previousOrderType = self.currentBehavior.order.OrderType
                    self.previousOrderTarget = self.currentBehavior.order.TargetIndex
                    self.previousOrderPosition = self.currentBehavior.order.Position
                end

            end
        end

        if self.currentBehavior.Think then self.currentBehavior:Think(self.thinkDuration) end

        return self.thinkDuration
    end

    function BehaviorSystem:ChooseNextBehavior()
        local result = nil
        local bestDesire = nil
        for _, behavior in pairs(self.possibleBehaviors) do
            local thisDesire = behavior:Evaluate()
            if bestDesire == nil or thisDesire > bestDesire then
                result = behavior
                bestDesire = thisDesire
            end
        end

        return result
    end

    function BehaviorSystem:Deactivate()
        print("End")
        if self.currentBehavior.End then self.currentBehavior:End() end
    end

    return BehaviorSystem
end


--------------------------------------------------------------------------------
function FindClosestEnemyInRange(entity, range, isHero, isVisiable)
    local enemies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, hThisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
    if #enemies > 0 then
        local index = RandomInt(1, #enemies)
        return enemies[index]
    else
        return nil
    end
end

function AttackNearestEnemy(hThisEntity)  --攻击最近的目标

    if not hThisEntity:IsAttacking() then

        local targets = FindUnitsInRadius(hThisEntity:GetTeamNumber(), hThisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)

        if #targets > 0 then  --避免打断攻击动作
            ExecuteOrderFromTable({
                UnitIndex = hThisEntity:entindex(),
                OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
                Position = targets[1]:GetOrigin()
            })
        end

    end

    return 0.5
end
--------------------------------------------------------------------------------