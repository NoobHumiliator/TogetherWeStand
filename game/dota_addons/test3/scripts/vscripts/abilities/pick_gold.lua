
function CheckToPickGold(keys)
    local caster	= keys.caster
	local ability	= keys.ability
	if caster:GetUnitName()=="npc_dota_courier" or  caster:IsRealHero() then
        
        local search_radius= 200

        if  caster and caster:GetUnitName()=="npc_dota_courier" then
            search_radius= 260   --信使拾取范围略微调大
        end

		local drop_items=Entities:FindAllByClassnameWithin("dota_item_drop",caster:GetAbsOrigin(),search_radius)
		for _, drop_item in pairs(drop_items) do     
	      local containedItem = drop_item:GetContainedItem()
	      --DeepPrint(containedItem:GetName())
	      if containedItem and containedItem:GetName()=="item_bag_of_gold_tws" then
	      	  local totalValue=containedItem:GetCurrentCharges()
	          local playerNumber=GameRules:GetGameModeEntity().Palyer_Number
	          local value=math.ceil(totalValue/playerNumber)

	      	 if caster:GetUnitName()=="npc_dota_courier" then --如果是信使          

                for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
					if PlayerResource:IsValidPlayer( nPlayerID ) then
						if PlayerResource:HasSelectedHero( nPlayerID ) then
							local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                            SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD, hero, value, nil )
                            PlayerResource:ModifyGold(nPlayerID,value,true,DOTA_ModifyGold_Unspecified)
					    end
					end
				end

	            UTIL_Remove(containedItem)              
	            UTIL_Remove( drop_item )
	         end
	         if caster:IsRealHero() then
                local hero = caster
	         	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
					if PlayerResource:IsValidPlayer( nPlayerID ) then
						if PlayerResource:HasSelectedHero( nPlayerID ) then
							local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
                            SendOverheadEventMessage( hero, OVERHEAD_ALERT_GOLD, hero, value, nil )
                            PlayerResource:ModifyGold(nPlayerID,value,true,DOTA_ModifyGold_Unspecified)
					    end
					end
				end
				UTIL_Remove(containedItem)              
	            UTIL_Remove( drop_item )
	         end      
	      end
	    end
	end
end