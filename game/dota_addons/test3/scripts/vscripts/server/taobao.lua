if Taobao == nil then Taobao = class({}) end

require('libraries/json')
require('util')
require('vip/vip_reward')

function Taobao:RegisterVip(code,steamID,nPlayerID)

    local request = CreateHTTPRequestScriptVM("GET", server_address .. "registervip")
    request:SetHTTPRequestGetOrPostParameter("register_type","taobao")
    request:SetHTTPRequestGetOrPostParameter("code",tostring(code))
    request:SetHTTPRequestGetOrPostParameter("steam_id",tostring(steamID))
    request:SetHTTPRequestGetOrPostParameter("auth","K4gN+u422RN2X4DubcLylw==")
    request:SetHTTPRequestGetOrPostParameter("dedicated_server_key",GetDedicatedServerKeyV2("K4gN+u422RN2X4DubcLylw=="))
    local sSteamID = tostring(steamID)
    request:Send(function(result)   --向服务器请求注册VIP
        print("Register result arrived: "..result.Body)
        if result.StatusCode == 200 then
            if result.Body=="already" then
               Notifications:Bottom(nPlayerID,{text="#code_already_used", duration=3, style={color="Red"}})
            elseif result.Body=="invalid" then
               Notifications:Bottom(nPlayerID,{text="#invalid_code", duration=3, style={color="Red"}})
            else
               local playerName=PlayerResource:GetPlayerName(nPlayerID)
               local heroName=PlayerResource:GetSelectedHeroName(nPlayerID)
               Notifications:BottomToAll({hero = heroName, duration = 5, continue = true})
               Notifications:BottomToAll({text = playerName.." ", duration = 5, continue = true})
               Notifications:BottomToAll({text = "#taobao_thank_note", duration = 5, style = {color = "Orange"}, continue = true})
               GrantExtraLife()  --给与队伍额外生命
               local keys={playerId=nPlayerID,vipLevel=tonumber(result.Body)}  --传回的是等级
               GameRules:GetGameModeEntity().CHoldoutGameMode.vipMap[steamID].level=tonumber(result.Body)
               CustomNetTables:SetTableValue( "vipMap", sSteamID, {level=tonumber(result.Body),validate_date=""} )
            end
        else
            print("Server return", result.StatusCode, result.Body)
        end
    end)

end