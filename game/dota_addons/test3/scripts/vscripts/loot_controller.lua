require("util")

if LootController == nil then
    LootController = class({})
end


bonusItems = {

    {
        "item_trail_tablet_1" --1
    },
    {
        "item_fallen_sword"  --2
    },
    {
        "item_skysong_blade"  --3
    },
    {
        "item_bloodsipper"   --4
    },
    {
        "item_unholy"        --5
    },
    {
        "item_water_sword"  --6
    },
    {
    --7
    },
    {
    --8
    },
    {
    --9
    },
    {
    --10
    },
    {
    --11
    },
    {
        "item_trail_tablet_2" --12
    }
}


--读取kv 加入掉落列表
function LootController:AddItemIntoBucket(itemListKV)
   
      for k, v in pairs(itemListKV) do
        --可以购买，或者可以出售 的物品加入掉落列表
        if type(v) == "table" and k ~= "item_rapier" and (v.ItemPurchasable == nil or v.ItemPurchasable == 1 or v.ItemSellable == 1) then
            local cost = GetItemCost(k)
            if cost > 200 then
                --1000 以上的物品 参与掉落
                if v.ItemRecipe == nil or cost >= 1000 then
                    self.dropItems[k] = cost
                end
                -- 高级物品 参与宝箱掉落
                if cost > 2000 then --高级装备参与宝箱掉落
                    local chestItem = { itemName = k, itemCost = cost }
                    table.insert(self.chestItems, chestItem)
                end
            end
        end
    end
end


function LootController:ReadConfigration()

    self._vHardLevelItemValue = {
        285, 225, 150
    }
    self.dropItems = {}
    self.chestItems = {} 
    
    local itemListKV = LoadKeyValues("scripts/kv/items_precache.txt")
    local itemCustomListKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    local itemOverrideListKV = LoadKeyValues("scripts/npc/npc_abilities_override.txt")
    LootController:AddItemIntoBucket(itemListKV)
    LootController:AddItemIntoBucket(itemCustomListKV)
    LootController:AddItemIntoBucket(itemOverrideListKV)

    table.sort(self.chestItems, function(a, b) return a.itemCost < b.itemCost end)
end


function LootController:SetItemProbability(roundNumber, hardLevel)

    local denominator = 0
    if hardLevel > 3 then
        hardLevel = 3
    end
    self._roundItemProbability = {}
    local average = self._vHardLevelItemValue[hardLevel] * math.pow(1.19, roundNumber) --item value*1.2^roundNumer
    local stdDeviation = average * (4 - hardLevel) * 0.7
    for k, v in pairs(self.dropItems) do
        denominator = denominator + NormalDistribution(v, average, stdDeviation)
    end
    for k, v in pairs(self.dropItems) do
        self._roundItemProbability[k] = NormalDistribution(v, average, stdDeviation) / denominator
    end
end


function LootController:CheckForLootItemDrop(roundNumber, dropNum, creatureNum, killedUnit)
    if dropNum / creatureNum > 2 then    --一个单位掉落多个物品
        local itemMultiNum = math.floor(dropNum / creatureNum)
        for i = 1, itemMultiNum do
            local newItemName = self:ChooseRandomItemName()
            self:LaunchWorldItemFromUnit(newItemName, RandomFloat(300, 450), 0.5, killedUnit)   --弹射物品  物品名称，高度，持续时间，单位
        end
    else
        if RandomFloat(0, 1) < dropNum / creatureNum then
            local newItemName = self:ChooseRandomItemName()
            self:LaunchWorldItemFromUnit(newItemName, RandomFloat(300, 450), 0.5, killedUnit)   --弹射物品  物品名称，高度，持续时间，单位
        end
    end
end


function LootController:LaunchWorldItemFromUnit(sItemName, flLaunchHeight, flDuration, hUnit)
    local newItem = CreateItem(sItemName, nil, nil)
    --print("itemname"..sItemName)
    newItem:SetPurchaseTime(0)
    if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
        newItem:SetStacksWithOtherOwners(true)
    end
    local newWorldItem = CreateItemOnPositionSync(hUnit:GetOrigin(), newItem)
    newWorldItem.Holdout_IsLootDrop = true
    newItem:LaunchLoot(false, flLaunchHeight, flDuration, hUnit:GetOrigin() + RandomVector(RandomFloat(200, 300)))
    Timers:CreateTimer({
        endTime = flDuration,
        callback = function()
            EmitGlobalSound("ui.inv_drop_highvalue")
        end
    })
end


function LootController:ChooseRandomItemName()
    local sNewItemName = nil
    while CreateItem(sNewItemName, nil, nil) == nil do   --防止物品不能被创建
        local temp = 0
        local randomNum = RandomFloat(0, 1)
        for k, v in pairs(self._roundItemProbability) do
            temp = temp + v
            if randomNum <= temp then
                sNewItemName = k
                break
            end
        end
    end
    return sNewItemName
end


function NormalDistribution(x, average, stdDeviation)
    return math.exp(math.pow(x - average, 2) / (-2 * math.pow(stdDeviation, 2))) / (math.sqrt(2 * math.pi) * stdDeviation)
end


function LootController:SpecialItemAdd(owner, level, nMaxRoundLevel)

    local addItemName = nil

    if bonusItems[level] == nil or #bonusItems[level] == 0 then  --如果奖励没定义 就从level/关卡数的分段里面取一个
        local index = RandomInt((level - 1) / nMaxRoundLevel * (#self.chestItems), level / nMaxRoundLevel * (#self.chestItems))
        addItemName = self.chestItems[index].itemName
    else
        local possibleItems = bonusItems[level]
        addItemName = PickRandom(possibleItems)
    end
    if string.find(addItemName, "item_trail_tablet") then  --如果是试炼符
        local hItem = CreateItem(addItemName, owner, owner)
        if GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty == 1 then
            hItem:SetCurrentCharges(16)
        elseif GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty == 2 then
            hItem:SetCurrentCharges(4)
        elseif GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty >= 3 then
            hItem:SetCurrentCharges(1)
        end
        AddItem(owner, hItem)
    else
        AddItemByName(owner, addItemName)
    end
    local particle = ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, owner)
    ParticleManager:ReleaseParticleIndex(particle)
    EmitGlobalSound("powerup_04")

end

function AddItem(owner, item)
    for i = 0, 14 do
        local currentSlotItem = owner:GetItemInSlot(i);
        if currentSlotItem == nil or (currentSlotItem:GetName() == item:GetName() and item:IsStackable()) then
            owner:AddItem(item)
            return
        end
    end
    local entities_dummy = Entities:FindByName(nil, "dummy_entities")
    local spawnPoint = entities_dummy:GetAbsOrigin()
    local drop = CreateItemOnPositionForLaunch(spawnPoint, item)
    item:LaunchLootInitialHeight(false, 0, 200, 0.25, spawnPoint)
end

function AddItemByName(owner, itemName)
    AddItem(owner, CreateItem(itemName, owner, owner))
end