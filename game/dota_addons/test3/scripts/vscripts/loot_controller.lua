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

function LootController:ReadConfigration()

    self._vHardLevelItemValue = {
        285, 225, 150
    }
    self._itemCost = {}
    self._itemCostSort = {} --排序版
    local itemListKV = LoadKeyValues("scripts/kv/items_precache.txt")
    for k, v in pairs(itemListKV) do
        if type(v) == "table" and k ~= "item_rapier" and (v.ItemPurchasable == nil or v.ItemPurchasable == 1) then
            local cost = GetItemCost(k)
            if cost > 200 then
                if v.ItemRecipe == nil or cost >= 1000 then
                    self._itemCost[k] = cost
                end
                if cost > 1500 then --2000以下的装备不参与
                    local sortItem = { itemName = k, itemCost = cost }
                    table.insert(self._itemCostSort, sortItem)
                end
            end
        end
    end
    local itemCsmListKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
    for k, v in pairs(itemCsmListKV) do
        if type(v) == "table" and (v.ItemPurchasable == nil or v.ItemPurchasable == 1) then  --必须是有价钱并且能买到的物品
            local cost = GetItemCost(k)
            if cost >= 200 then
                if v.ItemRecipe == nil or cost >= 1000 then
                    self._itemCost[k] = cost
                end
                if cost > 2500 then --2000以下的装备不参与
                    local sortItem = { itemName = k, itemCost = cost }
                    table.insert(self._itemCostSort, sortItem)
                end
            end
        end
    end
    table.sort(self._itemCostSort, function(a, b) return a.itemCost < b.itemCost end) --对物品价格进行排序
    --for k,v in pairs(self._itemCostSort) do
    --print("index: "..k.." itemName: "..v.itemName.."  itemCost: "..v.itemCost)
    --end
end


function LootController:SetItemProbability(roundNumber, hardLevel)

    local denominator = 0
    if hardLevel > 3 then
        hardLevel = 3
    end
    self._roundItemProbability = {}
    --self._valuetable={}
    --self._reverttable={}
    local average = self._vHardLevelItemValue[hardLevel] * math.pow(1.19, roundNumber) --item value*1.2^roundNumer
    local stdDeviation = average * (4 - hardLevel) * 0.7
    for k, v in pairs(self._itemCost) do
        denominator = denominator + NormalDistribution(v, average, stdDeviation)
    end
    for k, v in pairs(self._itemCost) do
        self._roundItemProbability[k] = NormalDistribution(v, average, stdDeviation) / denominator
        --以下注释
        --table.insert(self._valuetable, self._roundItemProbability[k])
        --self._reverttable[self._roundItemProbability[k]]=v
        --以上注释
    end
    --以下注释
    --table.sort(self._valuetable)
    --for _,v in pairs(self._valuetable) do
    --print(self._reverttable[v].."  "..v)
    --end
    --以上注释
end


function LootController:CheckForLootItemDrop(roundNumber, dropNum, creatureNum, killedUnit)
    --print("dropNum"..dropNum.."creatureNum"..creatureNum)
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
    --print( "Launching " .. newItem:GetName() .. " near " .. hUnit:GetUnitName() )
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
        local index = RandomInt((level - 1) / nMaxRoundLevel * (#self._itemCostSort), level / nMaxRoundLevel * (#self._itemCostSort))
        addItemName = self._itemCostSort[index].itemName
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