if LootController == nil then
  LootController = class({})
end


function LootController:ReadConfigration()
  self._itemCost={}
  local itemListKV = LoadKeyValues("scripts/kv/items_precache.txt")
  for k, v in pairs( itemListKV ) do
    if type( v ) == "table" and v.ItemCost and tonumber(v.ItemCost)~=0 then
       self._itemCost[k] = v.ItemCost
    end
  end
  local itemCsmListKV = LoadKeyValues("scripts/npc/npc_items_custom.txt")
  for k, v in pairs( itemCsmListKV ) do
    if type( v ) == "table" and v.ItemCost and tonumber(v.ItemCost)~=0 then
       self._itemCost[k] = v.ItemCost
    end
  end
end


function LootController:SetItemProbability(roundNumber,hardLevel)  

	local denominator=0
	self._roundItemProbability={}
	--self._valuetable={}
	--self._reverttable={}
	local exponent= -2.5+roundNumber*0.1+(3-hardLevel)*0.3   --每增加一关掉落品质增加0.1  困难难度无加成
	for k,v in pairs(self._itemCost) do
		denominator=denominator+v^exponent
	end
	for k,v in pairs(self._itemCost) do
		self._roundItemProbability[k]=(v^exponent)/denominator
		--table.insert(self._valuetable, self._roundItemProbability[k])
		--self._reverttable[self._roundItemProbability[k]]=v
		--print(k.."'s price:"..v.." probality:"..self._roundItemProbability[k])
	end
  --[[
	table.sort(self._valuetable)
	for _,v in pairs(self._valuetable) do
		print(self._reverttable[v].."  "..v)
	end
  ]]
end




function LootController:CheckForLootItemDrop( roundNumber,dropNum,creatureNum,killedUnit)
	print("dropNum"..dropNum.."creatureNum"..creatureNum)
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
	local newItemName=nil
	local temp=0
	local randomNum=math.random()
	for k,v in pairs(self._roundItemProbability) do
		temp=temp+self._roundItemProbability[k]
		if randomNum<=temp then
			newItemName=k
			break;
		end
	end
	return newItemName
end