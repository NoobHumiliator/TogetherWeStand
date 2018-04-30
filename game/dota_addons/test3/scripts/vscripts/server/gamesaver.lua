LinkLuaModifier( "modifier_water_sword_effect", "item_ability/modifier/modifier_water_sword_effect", LUA_MODIFIER_MOTION_NONE )

if GameSaver == nil then GameSaver = class({}) end  --存储游戏

require('libraries/json')
require('util')
local server_address="http://191.101.226.126:8005/"

prepareJsonData=""
nAcceptLoadPlayerNumber=0


function CHoldoutGameMode:SaveGame(keys)
  

  local slotIndex= keys.slotIndex
  local playerId= keys.playerId
  local jsonData = GameSaver:GameInfoToJson(playerId)
  local steamId = PlayerResource:GetSteamAccountID(playerId)
  local gameMode=GameRules:GetGameModeEntity().CHoldoutGameMode

  if gameMode._currentRound~=nil then
    Notifications:Bottom(keys.playerId, {text="#only_save_in_prepare", duration=2, style={color="Red"}})
    return 
  end
  
  if type(slotIndex)~="number" then  
    Notifications:Bottom(keys.playerId, {text="#please_select_one_slot", duration=2, style={color="Red"}})
    return 
  end


  if GameRules:IsCheatMode() and  IsDedicatedServer() then  --本机模式无视此项，随便存档
    Notifications:Bottom(keys.playerId, {text="#cheat_mode_can_not_save", duration=2, style={color="Red"}})
    return 
  end

  local request = CreateHTTPRequestScriptVM("GET", server_address .. "savegame")
  request:SetHTTPRequestGetOrPostParameter("saver_steam_id",tostring(steamId)); --游戏保存者的steamId
  request:SetHTTPRequestGetOrPostParameter("slot_index",tostring(slotIndex));  --存档槽的编号
  request:SetHTTPRequestGetOrPostParameter("json_data",tostring(jsonData));  --数据
  request:SetHTTPRequestGetOrPostParameter("auth","K4gN+u422RN2X4DubcLylw=="); --校验
  request:SetHTTPRequestGetOrPostParameter("dedicated_server_key",GetDedicatedServerKey("K4gN+u422RN2X4DubcLylw=="));



  request:Send(function(result)
      print("Save result arrived: "..result.Body)
      if result.StatusCode == 200 then
          if result.Body=="success" then  --保存成功
              CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"ReloadSavePanel",keys)
          end
      else
          print("Server return", result.StatusCode, result.Body);
          Notifications:BottomToAll( {text="Server Error, Try agian", duration=3, style={color="Red"}})
      end
  end)


end



function CHoldoutGameMode:PrepareToLoadGame(keys) --准备读取游戏
  
  prepareJsonData = keys.jsonData --向全局变量中存储玩家准备读取的信息
  nAcceptLoadPlayerNumber=0 --有几个玩家确认

  local data = JSON:decode(keys.jsonData)

  if data.playerNumber<GetValidPlayerNumber() then
     Notifications:Bottom(keys.playerId, {text="#player_number_should_less_than_save", duration=2, style={color="Red"}})
     return 
  end


  for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do  --处理英雄的预载入
      if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
         if  PlayerResource:HasSelectedHero( nPlayerID ) then
             local playerDetail = data[nPlayerID.."_playerData"]
             if alreadyCached[playerDetail.hero_name]==true then
             else        
                alreadyCached[playerDetail.hero_name] = true
                print('Precaching unit: '.. playerDetail.hero_name) 
                if unitExists('npc_precache_'.. playerDetail.hero_name) then     
                  PrecacheUnitByNameAsync('npc_precache_'.. playerDetail.hero_name, function() end)
                else
                  print('Failed to precache unit: npc_precache_'.. playerDetail.hero_name)
                end
             end
         end
      end
  end

  CustomGameEventManager:Send_ServerToTeam(DOTA_TEAM_GOODGUYS,"PopupLoadVote",{steamId=keys.steamId})  --所有玩家弹出投票信息
  Notifications:BottomToAll({text="#test_period_rank", duration=10, style={color="Red"}})
end


function CHoldoutGameMode:AcceptToLoadGame(keys) --准备读取游戏

  nAcceptLoadPlayerNumber=nAcceptLoadPlayerNumber+1 --确认玩家增加
  if nAcceptLoadPlayerNumber > nAcceptLoadPlayerNumber/2 then --如果超过半数玩家同意
      GameSaver:LoadGame(prepareJsonData)
  end
  
end



--记录用时关卡用时等级
function GameSaver:GameInfoToJson(playerId)
    
    local result={}
    result.vDropItems={}
    result.vBearItems={}
    local gameMode=GameRules:GetGameModeEntity().CHoldoutGameMode

    result.next_round = gameMode._nRoundNumber  --读取后下一关
    result.last_live = gameMode.last_live --剩余团队生命值
    result.vRoundSkip = gameMode.vRoundSkip --跳关记录
    result.map_difficulty = gameMode.map_difficulty --地图难度
    result.flDDadjust = gameMode.flDDadjust 
    result.flDHPadjust = gameMode.flDHPadjust
    result.nTimeCost = gameMode.nTimeCost --记录用时
    result.nMaxAttackSpeed=GameRules:GetGameModeEntity():GetMaximumAttackSpeed()
    result.heroLevels = {}
    result.heroGolds = {}
    result.heroAvgLevel= 1
    result.nHeroAvgGold= 625
    result.saverHeroName = PlayerResource:GetSelectedHeroEntity( playerId ):GetUnitName()
    --记录玩家状态
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
            if  PlayerResource:HasSelectedHero( nPlayerID ) then
              local playerDetail={}
              local vItems={}
              local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
              for i=0,11 do --遍历物品
                  local current_item = hero:GetItemInSlot(i)
                  if current_item then
                    local vCurrentItem={}
                    vCurrentItem.item_name=current_item:GetName()
                    --print("current_item:GetName()"..current_item:GetName())
                    if current_item:GetPurchaser() ~= nil then
                         vCurrentItem.purchaserPid=current_item:GetPurchaser():GetPlayerID() --记录下购买者的ID
                    end
                    vCurrentItem.charges=current_item:GetCurrentCharges()
                    table.insert(vItems,vCurrentItem)
                  end
              end

              playerDetail.vItems=vItems
              playerDetail.vAbilities=ListSaveAbilities(hero)
              playerDetail.vModifiers=ListSaveModifiers(hero)
              playerDetail.total_damage=vTotalDamageTable[nPlayerID]
              playerDetail.total_heal=vTotalHealTable[nPlayerID]
              --playerDetail.hero_level=hero:GetLevel()
              playerDetail.hero_name=hero:GetUnitName()
              playerDetail.gold=PlayerResource:GetGold(nPlayerID)
              playerDetail.exp = PlayerResource:GetTotalEarnedXP(nPlayerID)
              if gameMode.vXPBeforeMap[nPlayerID] then --保留下的实际经验应该减去读盘前的经验
                 playerDetail.exp=playerDetail.exp-gameMode.vXPBeforeMap[nPlayerID]
                 --print("playerDetail.exp"..playerDetail.exp)
              end
              playerDetail.abilityPoints=hero:GetAbilityPoints()
              table.insert(result.heroLevels,hero:GetLevel())
              table.insert(result.heroGolds,PlayerResource:GetTotalEarnedGold(nPlayerID)+625)
              result[nPlayerID.."_playerData"]=playerDetail
            end
        end
    end
    if #result.heroLevels>0 then  --计算英雄平均等级
       local sum=0
       for i=1,#result.heroLevels do
          sum=sum+result.heroLevels[i]
       end
       local goldSum=0
       for i=1,#result.heroGolds do
          goldSum=goldSum+result.heroGolds[i]
       end
       result.nHeroAvgLevel=sum/(#result.heroLevels)
       result.nHeroAvgGold=goldSum/(#result.heroLevels)
    end
    result.playerNumber=#result.heroLevels --有效玩家数量
    --记录地下物品状态
    local drop_items=Entities:FindAllByClassname("dota_item_drop")
    for _,drop_item in pairs(drop_items) do
        local vDropItem={}
        local containedItem = drop_item:GetContainedItem()
        local origin = drop_item:GetOrigin()
        vDropItem.x = origin.x
        vDropItem.y = origin.y
        vDropItem.z = origin.z
        if containedItem:GetPurchaser() ~= nil then
           vDropItem.purchaserPlayerId = containedItem:GetPurchaser():GetPlayerID() --购买者的ID
        end
        vDropItem.containedItemName=containedItem:GetName()
        vDropItem.charges=containedItem:GetCurrentCharges()
        table.insert(result.vDropItems,vDropItem)
    end
    --记录信使
    local couriersNumber=PlayerResource:GetNumCouriersForTeam(DOTA_TEAM_GOODGUYS)
    result.couriersNumber=couriersNumber
    if couriersNumber>0 then
        for i=1,couriersNumber do
          local courier=PlayerResource:GetNthCourierForTeam(i-1,DOTA_TEAM_GOODGUYS)
          local vCourierData={}
          vCourierData.itemsDetail={}
          if courier then
              for i=0,8 do --遍历物品
                  local current_item = courier:GetItemInSlot(i)
                  if current_item then
                      local vCourierItem = {}
                      vCourierItem.item_name=current_item:GetName()
                      vCourierItem.purchaserPid=current_item:GetPurchaser():GetPlayerID()
                      vCourierItem.charges=current_item:GetCurrentCharges()
                      table.insert(vCourierData.itemsDetail,vCurrentItem)
                  end
              end
              vCourierData.vAbilities=ListSaveAbilities(courier)
          end
          result[i.."_courierData"]=vCourierData
        end
    end
    --记录小熊
    local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    for _,unit in pairs(targets) do
        if string.find(unit:GetUnitName(),"npc_dota_lone_druid_bear") then --如果是小熊
            print("bearbearbear")
            for i=0,8 do --遍历物品
                  local current_item = unit:GetItemInSlot(i)
                  if current_item then
                      local vBearItem = {}
                      vBearItem.item_name=current_item:GetName()
                      print("name"..vBearItem.item_name)
                      if current_item:GetPurchaser() ~= nil then
                         vBearItem.purchaserPlayerId = current_item:GetPurchaser():GetPlayerID() --购买者的ID
                      end
                      vBearItem.purchaserPid=current_item:GetPurchaser():GetPlayerID()
                      vBearItem.charges=current_item:GetCurrentCharges()
                      table.insert(result.vBearItems,vBearItem)
                  end
            end
        end
    end
    
    return tostring(JSON:encode(result))
end


function GameSaver:LoadGame(sJsonData)   --从Json串读取数据

  local data = JSON:decode(sJsonData)
  local gameMode=GameRules:GetGameModeEntity().CHoldoutGameMode
  --还原全图最大攻速到600，银月后面给英雄一个个吃
  GameRules:GetGameModeEntity():SetMaximumAttackSpeed(600)


  gameMode.bLoadFlag=true  --记录此盘游戏是读盘的

  if gameMode._currentRound then
     gameMode._currentRound.achievement_flag=false --当前关卡成就失败
  end
  --还原全局变量
  print("Step1")
  gameMode._nRoundNumber = data.next_round
  gameMode.last_live = data.last_live --剩余团队生命值
  gameMode.vRoundSkip = data.vRoundSkip --跳关记录
  gameMode.map_difficulty = data.map_difficulty --地图难度
  gameMode.flDDadjust = data.flDDadjust 
  gameMode.flDHPadjust = data.flDHPadjust
  gameMode.nTimeCost = data.nTimeCost --还原用时
  gameMode.nLoadTime = gameMode.nLoadTime+1 --记录第几次读档
  --GameRules:GetGameModeEntity():SetMaximumAttackSpeed(data.nMaxAttackSpeed) --还原地图最大攻速
  print("Step2")
   --还原所选英雄
   for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
      if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then

          local nHeroID = PlayerResource:GetSelectedHeroID( nPlayerID )
          local playerDetail = data[nPlayerID.."_playerData"]

          vTotalDamageTable[nPlayerID] = playerDetail.total_damage
          vTotalHealTable[nPlayerID] = playerDetail.total_heal

          local newHero=nil
          if nHeroID == -1 then --如果没选英雄
              print("Step2.1: Create Hero for player "..nPlayerID)
              newHero=CreateHeroForPlayer(playerDetail.hero_name, PlayerResource:GetPlayer(nPlayerID))
          else
              --print("playerDetail.gold"..playerDetail.gold)
              print("Step2.1: Replace Hero for player "..nPlayerID)
              newHero=PlayerResource:ReplaceHeroWith(nPlayerID, playerDetail.hero_name, 0 , 0 )
          end
          print("Step2.2: newHero finished")
          gameMode.vXPBeforeMap[nPlayerID] = PlayerResource:GetTotalEarnedXP(nPlayerID) --记录下读盘前的经验
          --print("PlayerResource:GetTotalEarnedXP(nPlayerID)"..PlayerResource:GetTotalEarnedXP(nPlayerID))
          newHero:AddExperience(tonumber(playerDetail.exp),0,false,true)
          --newHero:SetAbilityPoints(playerDetail.abilityPoints)
          print("Step2.3: RemoveAllItems")
          RemoveAllItems(newHero)  --移除全部已有物品
          print("Step2.4: Add Abilities")
          for _,vAbility in pairs(playerDetail.vAbilities) do
              if newHero:HasAbility(vAbility.abilityName) then
                if string.sub(vAbility.abilityName,1,14)=="special_bonus_" then --如果是天赋技能
                   if vAbility.abilityLevel== 1 then --使用命令学习技能
                       local newAbility = newHero:FindAbilityByName(vAbility.abilityName)
                       --newAbility:UpgradeAbility(false)
                        ExecuteOrderFromTable({
                        UnitIndex = newHero:GetEntityIndex(),
                        OrderType = DOTA_UNIT_ORDER_TRAIN_ABILITY,
                        AbilityIndex = newAbility:GetEntityIndex()
                      })
                   end
                else
                    local newAbility = newHero:FindAbilityByName(vAbility.abilityName)
                    newAbility:SetLevel(vAbility.abilityLevel)
                    newAbility:SetAbilityIndex(vAbility.abilityIndex)
                    if vAbility.isHidden then
                       newAbility:SetHidden(true)
                    end
                end
              else
                UnitAddAbility(newHero,vAbility.abilityName,vAbility.abilityLevel,vAbility.abilityIndex,vAbility.isHidden) --如果没有技能 添加技能
              end
          end

          --一个BUFF一个BUFF的还原
          for _,vModifier in pairs(playerDetail.vModifiers) do
             if vModifier.modifierName=="modifier_item_dark_moon_shard" then
                for i=1,vModifier.modifierStack do
                    local item=newHero:AddItemByName("item_dark_moon_shard")
                    ExecuteOrderFromTable({  --使用暗月
                      UnitIndex = newHero:entindex(),
                      OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                      AbilityIndex = item:entindex()
                    })
                end
             end
             if vModifier.modifierName=="modifier_item_mulberry" then
                for i=1,vModifier.modifierStack do
                    local item=newHero:AddItemByName("item_mulberry")
                    ExecuteOrderFromTable({  --使用桑葚
                      UnitIndex = newHero:entindex(),
                      OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                      AbilityIndex = item:entindex()
                    })
                end
             end
             if vModifier.modifierName=="modifier_item_moon_shard_consumed" then
                local item=newHero:AddItemByName("item_moon_shard")
                ExecuteOrderFromTable({  --使用银月
                  UnitIndex = newHero:entindex(),
                  OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                  TargetIndex = newHero:entindex(),
                  AbilityIndex = item:entindex()
                })
             end
             if vModifier.modifierName=="modifier_extra_slot_7_consume" then
                local item=newHero:AddItemByName("item_extra_slot_7")
                ExecuteOrderFromTable({  --使用无限法球
                  UnitIndex = newHero:entindex(),
                  OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                  TargetIndex = newHero:entindex(),
                  AbilityIndex = item:entindex()
                })
             end
             if vModifier.modifierName=="modifier_extra_slot_8_consume" then
                local item=newHero:AddItemByName("item_extra_slot_8")
                ExecuteOrderFromTable({  --使用无限法球
                  UnitIndex = newHero:entindex(),
                  OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                  TargetIndex = newHero:entindex(),
                  AbilityIndex = item:entindex()
                })
             end
             if vModifier.modifierName=="modifier_extra_slot_9_consume" then
                local item=newHero:AddItemByName("item_extra_slot_9")
                ExecuteOrderFromTable({  --使用无限法球
                  UnitIndex = newHero:entindex(),
                  OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
                  TargetIndex = newHero:entindex(),
                  AbilityIndex = item:entindex()
                })
             end
             if vModifier.modifierName=="modifier_item_ultimate_scepter_consumed" then
                newHero:AddNewModifier(newHero, nil, "modifier_item_ultimate_scepter_consumed", {duration = -1})
             end
             if vModifier.modifierName=="modifier_water_sword_effect" then
                newHero:AddNewModifier(newHero, nil, "modifier_water_sword_effect", {})
                newHero:SetModifierStackCount("modifier_water_sword_effect", nil, vModifier.modifierStack)
             end
          end

          --还原鸟的数量
          print("Step2.5: Restore Courier Number")
          if nPlayerID==0 then
             while PlayerResource:GetNumCouriersForTeam(DOTA_TEAM_GOODGUYS)<data.couriersNumber do --如果信使数量不足，补足数量
                local courier_item = newHere:AddItemByName("item_courier")  --给予信使物品
                ExecuteOrderFromTable({  --召唤信使
                  UnitIndex = newHero:entindex(),
                  OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
                  AbilityIndex = courier_item:entindex()
                })
             end
          end
      end
   end
    --创建完英雄后还原物品
   print("Step3")
   for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
      local playerDetail = data[nPlayerID.."_playerData"]
      if playerDetail then
          local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
          for i=1,#playerDetail.vItems do --为英雄补充物品
            local item = playerDetail.vItems[i]
            local owner = nil
            if item.purchaserPlayerId then
               owner = PlayerResource:GetSelectedHeroEntity( item.purchaserPlayerId )
            end
            local newItem = CreateItem(item.item_name,owner,owner)
            newItem:SetCurrentCharges(item.charges)
            hero:AddItem(newItem)
          end 
      end      
   end
   --还原鸟的物品 技能
   print("Step4")
   local couriersNumber=PlayerResource:GetNumCouriersForTeam(DOTA_TEAM_GOODGUYS)
   if couriersNumber>0 then
      for i=1,couriersNumber do
        local courier=PlayerResource:GetNthCourierForTeam(i-1,DOTA_TEAM_GOODGUYS)
        if courier then
            for _,itemInfo in pairs(data[i.."_courierData"].itemsDetail) do
               local owner = nil 
               if itemInfo.purchaserPid then
                  owner = PlayerResource:GetSelectedHeroEntity( itemInfo.purchaserPid )
               end
               local newItem = CreateItem(itemInfo.item_name,owner,owner)
               newItem:SetCurrentCharges(itemInfo.charges)
               courier:AddItem(newItem)
            end
            RemoveAllAbilities(courier)
            for _,vAbility in pairs(data[i.."_courierData"].vAbilities) do
               UnitAddAbility(courier,vAbility.abilityName,vAbility.abilityLevel,vAbility.abilityIndex,vAbility.isHidden) --添加技能
            end
        end
      end
   end
   --跳到指定关 注意此操作会清除地上物品
   print("Step5")
   gameMode:TestRound(gameMode._nRoundNumber)

   --还原地上物品
   print("Step6")
   for _,vDropItem in pairs(data.vDropItems) do
        local owner = nil
        if vDropItem.purchaserPlayerId then
           owner = PlayerResource:GetSelectedHeroEntity( vDropItem.purchaserPlayerId )
        end
        local newItem = CreateItem( vDropItem.containedItemName, owner, owner )
        newItem:SetCurrentCharges(vDropItem.charges)
        CreateItemOnPositionSync( Vector(vDropItem.x,vDropItem.y,vDropItem.z), newItem )
   end
   --将小熊里面的物品直接扔地上
   print("Step7")
   for _,vBearItem in pairs(data.vBearItems) do
        local owner = nil
        if vBearItem.purchaserPlayerId then
           owner = PlayerResource:GetSelectedHeroEntity( vBearItem.purchaserPlayerId )
        end
        local newItem = CreateItem( vBearItem.item_name, owner, owner )
        newItem:SetCurrentCharges(vBearItem.charges)
        local center = Entities:FindByName(nil,"rattlewaypoint_2" ):GetOrigin() --随便找个地方往家附近
        CreateItemOnPositionSync( Vector(center.x+RandomInt(-200,200),center.y+RandomInt(-200,200),center.z), newItem )
   end
   print("Step8")
   for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do  --不知道为什么，需要重置金钱,重置技能点
      if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
          if  PlayerResource:HasSelectedHero( nPlayerID ) then
              local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
              local playerDetail = data[nPlayerID.."_playerData"]
              PlayerResource:ResetTotalEarnedGold(nPlayerID) --重置经济            
              hero:SetGold(playerDetail.gold,true)
              hero:SetAbilityPoints(playerDetail.abilityPoints)
          end
      end
   end
end




function UnitAddAbility(unit,abilityName,level,index,isHidden)

     unit:AddAbility(abilityName)          
     if manualActivate[abilityName] then  --激活光法的两个技能
       local ab = unit:FindAbilityByName(abilityName)
       if ab then
          ab:SetActivated(true)
       end
     end
     --处理预载入
     ------------------------------------------------
     if  CHoldoutGameMode._vHeroList[abilityName]~=nil then
      if alreadyCached[ CHoldoutGameMode._vHeroList[abilityName]]==true then
      else        
        alreadyCached[ CHoldoutGameMode._vHeroList[abilityName]] = true
        print('Precaching unit: '.. CHoldoutGameMode._vHeroList[abilityName]) 
        if unitExists('npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName]) then     
          PrecacheUnitByNameAsync('npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName], function() end)
        else
          print('Failed to precache unit: npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName])
        end
      end
     else
      PrecacheUnitByNameAsync('npc_precache_'..abilityName, function() end)    --自定义的技能需要单独加载         
     end 
     --处理等级位置------------------------------------------------------ 
     local ability = unit:FindAbilityByName(abilityName)
     ability:SetLevel(level)
     if isHidden then
       ability:SetHidden(true)
     else
       ability:SetHidden(false)
     end
     ability:SetAbilityIndex(index)
             
     if brokenModifierAbilityMap[abilityName]~=nil then
         local modifier = unit:FindModifierByName(brokenModifierAbilityMap[abilityName])
         if modifier then
              local stack= brokenModifierCounts[brokenModifierAbilityMap[abilityName]]
              modifier:SetStackCount(stack)
         end
     end
end


function RemoveAllItems(unit)

     for i=0,11 do --遍历物品
        local item = unit:GetItemInSlot(i)
        if item then
           UTIL_Remove(item)
        end
     end

end
