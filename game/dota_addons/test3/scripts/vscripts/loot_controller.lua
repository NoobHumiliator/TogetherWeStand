require("util")

if LootController == nil then
  LootController = class({})
end



function LootController:ReadConfigration()

  self._vHardLevelItemValue={
	500,400,300
  }
  self._itemCost={}
  local itemListKV = LoadKeyValues("scripts/kv/items_precache.txt")
  for k, v in pairs( itemListKV ) do
    if type( v ) == "table" and v.ItemCost and tonumber(v.ItemCost)~=0 then
       self._itemCost[k] = v.ItemCost
    end
  end
  local itemCsmListKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  for k, v in pairs( itemCsmListKV ) do
    if type( v ) == "table" and v.ItemCost and tonumber(v.ItemCost)~=0  and  (v.ItemPurchasable==nil or  (v.ItemPurchasable and v.ItemPurchasable==1) )  then  --必须是有价钱并且能买到的物品
       --print("costom item"..k)
       self._itemCost[k] = v.ItemCost
    end
  end
end


function LootController:SetItemProbability(roundNumber,hardLevel)  

	local denominator=0
	if hardLevel>3 then
	   hardLevel=3
    end
	self._roundItemProbability={}
	self._valuetable={}
	self._reverttable={}
	local average= self._vHardLevelItemValue[hardLevel]*roundNumber --基础的item value*关卡数
	local stdDeviation= average*(4-hardLevel)*0.5
	for k,v in pairs(self._itemCost) do
		denominator=denominator+NormalDistribution(v,average,stdDeviation)
	end
	for k,v in pairs(self._itemCost) do
		self._roundItemProbability[k]=NormalDistribution(v,average,stdDeviation)/denominator
		--以下注释
		table.insert(self._valuetable, self._roundItemProbability[k])
		self._reverttable[self._roundItemProbability[k]]=v
		--以上注释
	end
    --以下注释
	table.sort(self._valuetable)
	for _,v in pairs(self._valuetable) do
		print(self._reverttable[v].."  "..v)
	end
    --以上注释
end




function LootController:CheckForLootItemDrop( roundNumber,dropNum,creatureNum,killedUnit)
	--print("dropNum"..dropNum.."creatureNum"..creatureNum)
	if dropNum/creatureNum>2 then    --一个单位掉落多个物品
		local itemMultiNum=math.floor(dropNum/creatureNum)
		for i=1,itemMultiNum do
            local newItemName=self:ChooseRandomItemName()
			self:LaunchWorldItemFromUnit(newItemName,RandomFloat( 300, 450 ),0.5,killedUnit)   --弹射物品  物品名称，高度，持续时间，单位
		end
	else
		if math.random() < dropNum/creatureNum then
			local newItemName=self:ChooseRandomItemName()
			self:LaunchWorldItemFromUnit(newItemName,RandomFloat( 300, 450 ),0.5,killedUnit)   --弹射物品  物品名称，高度，持续时间，单位
		end
	end
end


function LootController:LaunchWorldItemFromUnit( sItemName, flLaunchHeight, flDuration, hUnit )
    local newItem = CreateItem( sItemName, nil, nil )
    --print("itemname"..sItemName)
    newItem:SetPurchaseTime( 0 )
    if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
		 newItem:SetStacksWithOtherOwners( true )
	end
    local newWorldItem = CreateItemOnPositionSync( hUnit:GetOrigin(), newItem )
    newWorldItem.Holdout_IsLootDrop = true
	newItem:LaunchLoot( false, flLaunchHeight, flDuration, hUnit:GetOrigin() + RandomVector( RandomFloat( 200, 300 ) ) )
	--print( "Launching " .. newItem:GetName() .. " near " .. hUnit:GetUnitName() )
	Timers:CreateTimer({
    endTime = flDuration, 
    callback = function()
    EmitGlobalSound( "ui.inv_drop_highvalue" )
    end
    })
end


function LootController:ChooseRandomItemName()
	local sNewItemName=nil
	while  CreateItem( sNewItemName, nil, nil )==nil  do   --防止物品不能被创建
		local temp=0
		local randomNum=math.random()
		for k,v in pairs(self._roundItemProbability) do
			temp=temp+self._roundItemProbability[k]
			if randomNum<=temp then
				sNewItemName=k
				break;
			end
		end
	end
	return sNewItemName
end



function NormalDistribution (x,average,stdDeviation)
	return math.exp( math.pow(x-average,2)/ (-2*math.pow(stdDeviation,2)) ) / (math.sqrt(2*math.pi)*stdDeviation)
end