if Detail == nil then Detail = class({}) end

require('libraries/json')
require('util')
local server_address="http://191.101.226.126:8005/"

vTotalDamageTable={} --全局变量统计总伤害 
vTotalHealTable={} --全局变量统计总治疗
vFailedRound={} --失败关卡


for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
    vTotalDamageTable[nPlayerID] = 0
    vTotalHealTable[nPlayerID]=0
end



--记录用时关卡用时等级
function Detail:RecordDetail(nRoundNumber,nDifficulty)
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
              local playerDetail={}
              playerSteamIDs=playerSteamIDs..PlayerResource:GetSteamAccountID(nPlayerID)..";"
              player_number=player_number+1
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
              table.insert(playerDetails,playerDetail)
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
    request:SetHTTPRequestGetOrPostParameter("player_details",JSON:encode(playerDetails))
    print("Recording detail : player_details: "..tostring(JSON:encode(playerDetails)).." time_cost: "..tostring(nTimeCost).." max_round: "..nRoundNumber)
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