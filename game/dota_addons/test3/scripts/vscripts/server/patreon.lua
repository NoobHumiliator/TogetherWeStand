if Patreon == nil then Patreon = class({}) end

require('libraries/json')
require('util')
require('vip/vip_reward')

rewardLevelTable={ [1557280]=2 }   --Reward与Vip等级的关系


function Patreon:GetPatrons(emailCode,steamID,nPlayerID)
    local patreonRequest = CreateHTTPRequestScriptVM("GET", "https://api.patreon.com/oauth2/api/campaigns/824833/pledges")
    patreonRequest:SetHTTPRequestHeaderValue("Authorization","Bearer Zutt4TQWsM0b7FtzxqhDHRgR2wHM81")
    --print("steamID"..steamID)
    patreonRequest:Send(function(result)
        if result.StatusCode == 200 then
            print("Server return success")
            local resultTable= JSON:decode(result.Body)
            for _,v in pairs(resultTable.data) do

              local patreon_id=v.relationships.patron.data.id
              local rewardLevel=rewardLevelTable[tonumber(v.relationships.reward.data.id)]
              print("patreon_id:"..patreon_id.."  rewardLevel:"..rewardLevel)

              if rewardLevel~=nil then  --如果奖励类型能对得起来
                for _,v in pairs(resultTable.included) do  --遍历详情

                  if v.type=="user" and v.id==patreon_id then
                     print("emailCode"..emailCode.."v.attributes.email"..v.attributes.email)
                  end
                  if v.type=="user" and v.id==patreon_id and emailCode==string.lower(v.attributes.email) then --如果找到的ID用户Email
                      print("v.attributes.email"..string.lower(v.attributes.email).."emailCode"..emailCode)
                      local request = CreateHTTPRequestScriptVM("GET", server_address .. "registervip")
                      request:SetHTTPRequestGetOrPostParameter("register_type","patreon")
                      request:SetHTTPRequestGetOrPostParameter("code",tostring(emailCode))
                      request:SetHTTPRequestGetOrPostParameter("steam_id",tostring(steamID))
                      request:SetHTTPRequestGetOrPostParameter("vip_level",tostring(rewardLevel))
                      request:SetHTTPRequestGetOrPostParameter("auth","K4gN+u422RN2X4DubcLylw==")
                            request:Send(function(result)   --向服务器请求注册VIP
                                print("Register result arrived: "..result.Body)
                                if result.StatusCode == 200 then
                                    if result.Body=="already" then
                                       Notifications:Bottom(nPlayerID,{text="#email_already_bind", duration=3, style={color="Red"}})
                                    else
                                       Notifications:Bottom(nPlayerID,{text="#register_success", duration=3, style={color="Red"}})
                                       local playerName=PlayerResource:GetPlayerName(nPlayerID)
                                       local heroName=PlayerResource:GetSelectedHeroName(nPlayerID)
                                       Notifications:BottomToAll({text = "#patreon_thank_note_1", duration = 5, style = {color = "Orange"}})
                                       Notifications:BottomToAll({hero = heroName, duration = 5, continue = true})
                                       Notifications:BottomToAll({text = playerName.." ", duration = 5, continue = true})
                                       Notifications:BottomToAll({text = "#patreon_thank_note_2", duration = 5, style = {color = "Orange"}, continue = true})
                                       GrantExtraLife()  --给与队伍额外生命
                                       local keys={playerId=nPlayerID,vipLevel=rewardLevel}  --传回的是等级
                                    end
                                else
                                    print("Server return", result.StatusCode, result.Body)
                                end
                            end)
                  end
                end
              end
            end
        else
            print("Server return fail", result.StatusCode, result.Body)
        end
    end)
end