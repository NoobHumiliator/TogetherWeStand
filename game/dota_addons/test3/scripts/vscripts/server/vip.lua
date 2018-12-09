if Vip == nil then Vip = class({}) end

require('libraries/json')
require('util')


function Vip:GetVipDataFromServer(steamIDs)
    if self.rankTable ==nil then self.rankTable={} end
    if self.rankTable[nPlayerNumber]==nil then  --数据集中没有对应数据
        local playerNumberTable={}   --新建一个数据表      
        local player_number=tostring(nPlayerNumber)
        local request = CreateHTTPRequestScriptVM("GET", server_address .. "queryvip")
        request:SetHTTPRequestGetOrPostParameter("steam_ids",tostring(steamIDs));
        request:Send(function(result)
            print("Vip data arrived: "..result.Body)
            if result.StatusCode == 200 then
                local result_table = JSON:decode(result.Body);
                --PrintTable(result_table,nil,nil)
                for _,v in ipairs(result_table) do
                     --高速通道缓存VIP状态 key是玩家steam_id
                     CustomNetTables:SetTableValue( "vipMap", tostring(v.steam_id), {level=tonumber(v.level),validate_date=v.validate_date} )
                     GameRules:GetGameModeEntity().CHoldoutGameMode.vipMap[tonumber(v.steam_id)].level=tonumber(v.level)
                     GameRules:GetGameModeEntity().CHoldoutGameMode.vipMap[tonumber(v.steam_id)].validDateUTC=v.validate_date
                end             
            else
                print("Server return", result.StatusCode, result.Body);             
            end
        end)
    end
end