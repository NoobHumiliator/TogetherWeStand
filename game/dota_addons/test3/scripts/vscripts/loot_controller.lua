if LootController == nil then
  LootController = class({})
end


function LootController:ReadConfigration()
  self._itemCost={}
  local itemListKV = LoadKeyValues("scripts/kv/npc_items_precache.txt")
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



function CHoldoutGameMode:CheckForLootItemDrop( roundNumber,dropNum,creatureNum )
  for _,itemDropInfo in pairs( self._vLootItemDropsList ) do
    if RollPercentage( dropNum/creatureNum) then
      local newItem = CreateItem( itemDropInfo.szItemName, nil, nil )
      newItem:SetPurchaseTime( 0 )
      if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
        item:SetStacksWithOtherOwners( true )
      end
      local drop = CreateItemOnPositionSync( killedUnit:GetAbsOrigin(), newItem )
      drop.Holdout_IsLootDrop = true
    end
  end
end