if Rank == nil then Rank = class({}) end

require('libraries/json')
require('util')
local server_address="http://54.68.31.237:8005/"

function Rank:Start()
   CustomGameEventManager:RegisterListener("RequestRankData", Dynamic_Wrap(Rank, 'RequestRankData'))
end

function Rank:RequestRankData(keys)
    local player_number=keys.player_number
    local page_number=keys.page_number
    print("player number: "..player_number)
    print("page number: "..page_number)
    if Rank.rankTable ~=nil then
        CustomGameEventManager:Send_ServerToAllClients("show_page", {player_number=player_number,page_number=page_number,table=Rank.rankTable[tonumber(player_number)][tonumber(page_number)]})
    end
end





function Rank:GetRankDataFromServer(nPlayerNumber)
    if self.rankTable ==nil then self.rankTable={} end--创建玩家天梯数据集
    if self.rankTable[nPlayerNumber]==nil then  --数据集中没有对应数据
        local playerNumberTable={}   --新建一个数据表      
        local player_number=tostring(nPlayerNumber)
        local request = CreateHTTPRequestScriptVM("GET", server_address .. "getrankdata")
        request:SetHTTPRequestGetOrPostParameter("player_number",player_number);
        request:Send(function(result)
            print("Rank data arrived: "..result.Body)
            if result.StatusCode == 200 then
                local result_table = JSON:decode(result.Body);
                --PrintTable(result_table,nil,nil)
                for i,v in ipairs(result_table) do
                    --PrintTable(v,nil,nil)
                    local page=math.ceil(i/150) --1到150是第一页 151-300 第二页 分页保存至表中
                    if playerNumberTable[page]==nil then playerNumberTable[page]={} end
                    table.insert(playerNumberTable[page],v)
                end
                Rank.rankTable[nPlayerNumber]=playerNumberTable
                --PrintTable(Rank.rankTable,nil,nil)
                if playerNumberTable[1]~=nil then --如果第一页数据不为空,显示第一页数据
                  CustomGameEventManager:Send_ServerToAllClients("show_page", {player_number=player_number,page_number=1,table=playerNumberTable[1]})
                end
            else
                print("Server return", result.StatusCode, result.Body);             
            end
        end)
    end
end

function Rank:RecordGame(nRoundNumber,nLoser)
    local playerSteamIDs=""   --玩家SteamId串（排序后）
    local vPlayerSteamIDs={}  --玩家SteamId表
    local player_number=0;
    local steamGameId=GameRules:GetMatchID()
    if tostring(steamGameId)=="0" then
       steamGameId=GetSystemTime().."_"..RandomInt(0,99999999)
    end
    local nTimeCost=math.floor(GameRules:GetGameTime())
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
        if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
            if  PlayerResource:HasSelectedHero( nPlayerID ) then           
              table.insert(vPlayerSteamIDs,PlayerResource:GetSteamAccountID(nPlayerID))  --压入表
              player_number=player_number+1
            end
        end
    end
    table.sort(vPlayerSteamIDs)  --排序
    for i=1,#vPlayerSteamIDs do
        playerSteamIDs=playerSteamIDs..vPlayerSteamIDs[i]..";"
    end

    if string.sub(playerSteamIDs,string.len(playerSteamIDs))==";" then   --去掉最后一个;
        playerSteamIDs=string.sub(playerSteamIDs,0,string.len(playerSteamIDs)-1)
    end
    local request = CreateHTTPRequestScriptVM("GET", server_address .. "recordgame")
    request:SetHTTPRequestGetOrPostParameter("steam_game_id",tostring(steamGameId));
    request:SetHTTPRequestGetOrPostParameter("max_round",tostring(nRoundNumber));
    request:SetHTTPRequestGetOrPostParameter("player_steam_ids",playerSteamIDs);
    request:SetHTTPRequestGetOrPostParameter("time_cost",tostring(nTimeCost));
    request:SetHTTPRequestGetOrPostParameter("player_number",tostring(player_number));
    request:SetHTTPRequestGetOrPostParameter("auth","K4gN+u422RN2X4DubcLylw==");
    print("Recording game: steam_game_id:"..tostring(steamGameId).." max_round: "..tostring(nRoundNumber).." time_cost: "..tostring(nTimeCost).." player_number: "..player_number)
    print("Player steam ids: "..playerSteamIDs)
    request:Send(function(result)
            print("Record result arrived: "..result.Body)
            if result.StatusCode == 200 then
                if result.Body=="Not good enough" then
                    print("Not good enough")
                    GameRules:MakeTeamLose(nLoser)
                elseif result.Body=="Dupulicate game id" then
                   Notifications:BottomToAll( {text="Sorry, record fail due to dupulicate game id (>﹏<)", duration=3, style={color="Red"}})
                   Timers:CreateTimer({
                            endTime = 3, 
                              callback = function()
                              GameRules:MakeTeamLose(nLoser)
                            end})
                else
                   local nNewRank= tonumber(result.Body)
                   CustomGameEventManager:Send_ServerToAllClients("AnnounceNewRank",{new_rank=tostring(nNewRank)}) --前台显示新排名
                    Timers:CreateTimer({
                            endTime = 10, 
                              callback = function()
                              GameRules:MakeTeamLose(nLoser)
                            end})
                end
            else
                print("Server return", result.StatusCode, result.Body);
                Notifications:BottomToAll( {text="#server_error,can not record the g (>﹏<)", duration=3, style={color="Red"}})
                Timers:CreateTimer({
                            endTime = 3, 
                              callback = function()
                              GameRules:MakeTeamLose(nLoser)
                            end})
            end
        end)
end










Rank:Start()