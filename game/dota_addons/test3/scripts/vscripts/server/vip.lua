if Vip == nil then Vip = class({}) end

require('libraries/json')
require('util')

local server_address="http://54.68.31.237:8005/"


function Vip:GetVipDataFromServer(steamIDs)
    if self.rankTable ==nil then self.rankTable={} end--创建玩家天梯数据集
    if self.rankTable[nPlayerNumber]==nil then  --数据集中没有对应数据
        local playerNumberTable={}   --新建一个数据表      
        local player_number=tostring(nPlayerNumber)
        local request = CreateHTTPRequestScriptVM("GET", server_address .. "queryvip")
        --print("steam_ids"..steamIDs)
        request:SetHTTPRequestGetOrPostParameter("steam_ids",tostring(steamIDs));
        request:Send(function(result)
            print("Vip data arrived: "..result.Body)
            if result.StatusCode == 200 then
                local result_table = JSON:decode(result.Body);
                --PrintTable(result_table,nil,nil)
                for _,v in ipairs(result_table) do
                     GameRules:GetGameModeEntity().CHoldoutGameMode.vipMap[tonumber(v.steam_id)]=tonumber(v.level)
                     local playerId=GameRules:GetGameModeEntity().CHoldoutGameMode.steamIdMap[tonumber(v.steam_id)]
                     local keys={playerId=playerId,vipLevel=v.level}                  
                     --PrintTable(keys)
                     CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId),"NotifyVip", keys) --将VIP等级告知前台
                end             
            else
                print("Server return", result.StatusCode, result.Body);             
            end
        end)
    end
end
