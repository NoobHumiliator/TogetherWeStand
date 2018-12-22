if Detail == nil then Detail = class({}) end

require('libraries/json')
require('util')

vTotalDamageTable={} --全局变量统计总伤害 
vTotalHealTable={} --全局变量统计总治疗
vFailedRound={} --失败关卡
vPlayerStatusSnapshots={} --每关状态快照

for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    vTotalDamageTable[nPlayerID] = 0
    vTotalHealTable[nPlayerID]=0
end



--记录游戏细节
function Detail:RecordDetail()
     
    local nRoundNumber = GameRules:GetGameModeEntity().CHoldoutGameMode._nRoundNumber-1
    local nDifficulty = GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty

    local playerSteamIDs="";
    local player_number=0;
    local steamGameId=GameRules:GetMatchID()
    if tostring(steamGameId)=="0" then
       steamGameId=GetSystemTime().."_"..RandomInt(0,99999999)
    end
    local playerDetails={}

    local nTimeCost=math.floor(GameRules:GetGameTime())
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
            if  PlayerResource:HasSelectedHero( nPlayerID ) then
              playerSteamIDs=playerSteamIDs..PlayerResource:GetSteamAccountID(nPlayerID)..";"
              player_number=player_number+1
            end
        end
    end

    if string.sub(playerSteamIDs,string.len(playerSteamIDs))==";" then   --去掉最后一个;
        playerSteamIDs=string.sub(playerSteamIDs,0,string.len(playerSteamIDs)-1)
    end
    local request = CreateHTTPRequestScriptVM("GET", server_address .. "recorddetail")
    request:SetHTTPRequestGetOrPostParameter("steam_game_id",tostring(steamGameId))
    request:SetHTTPRequestGetOrPostParameter("max_round",tostring(nRoundNumber))
    request:SetHTTPRequestGetOrPostParameter("player_steam_ids",playerSteamIDs)
    request:SetHTTPRequestGetOrPostParameter("time_cost",tostring(nTimeCost))
    request:SetHTTPRequestGetOrPostParameter("player_number",tostring(player_number))
    request:SetHTTPRequestGetOrPostParameter("difficulty",tostring(nDifficulty))
    request:SetHTTPRequestGetOrPostParameter("auth","K4gN+u422RN2X4DubcLylw==")
    request:SetHTTPRequestGetOrPostParameter("fail_details",JSON:encode(vFailedRound))  
    request:SetHTTPRequestGetOrPostParameter("player_details",JSON:encode(vPlayerStatusSnapshots))
    request:SetHTTPRequestGetOrPostParameter("dedicated_server_key",GetDedicatedServerKey("K4gN+u422RN2X4DubcLylw=="));

    print("Fail details: "..tostring(JSON:encode(vFailedRound)))
    request:Send(function(result)
        print("Detail result arrived: "..result.Body)
        if result.StatusCode == 200 then
            if result.Body=="Dupulicate game id" then                  
               print("dupulicate game id", result.StatusCode, result.Body);                   
            else
               print("record detail success", result.StatusCode, result.Body);                                   
            end
        else
            print("Server return", result.StatusCode, result.Body);
        end
    end)
end



--记录玩家状态快照   bPass是否过关 
function Detail:InsertPlayerStatusSnapshot(bPass)
     
    local nRoundNumber = GameRules:GetGameModeEntity().CHoldoutGameMode._nRoundNumber
    local nDifficulty = GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty
    local nBranchIndex = GameRules:GetGameModeEntity().CHoldoutGameMode._nBranchIndex


    local vResult={}
    vResult.round_number=nRoundNumber.."_"..nBranchIndex
    vResult.map_difficulty=nDifficulty

    local nTimeCost=math.floor(GameRules:GetGameTime())
    vResult.time_cost=nTimeCost

    vResult.pass=bPass

    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
            if  PlayerResource:HasSelectedHero( nPlayerID ) then
              local playerDetail={}
              playerDetail.steam_id=PlayerResource:GetSteamAccountID(nPlayerID)
              local itemNames="";
              local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
              for i=0,8 do --遍历物品
                  local current_item = hero:GetItemInSlot(i)
                  if current_item ~= nil then         
                      itemNames=itemNames..current_item:GetName()..";"
                  end
              end
              playerDetail.item_names=itemNames
              playerDetail.ability_names=ListLearnedAbilities(hero)
              playerDetail.total_damage=tostring(vTotalDamageTable[nPlayerID])
              playerDetail.total_heal=tostring(vTotalHealTable[nPlayerID])
              playerDetail.hero_level=tostring(hero:GetLevel())
              playerDetail.hero_name=tostring(hero:GetUnitName())
              playerDetail.gold=tostring(PlayerResource:GetGold(nPlayerID))
              table.insert(vResult,playerDetail)
            end
        end
    end

    table.insert(vPlayerStatusSnapshots,vResult)
end