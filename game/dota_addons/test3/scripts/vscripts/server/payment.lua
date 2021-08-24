if Payment == nil then Payment = class({}) end

function Payment:Init()
    CustomGameEventManager:RegisterListener("CreatePayment",function(_, keys)
        self:CreatePayment(keys)
    end)

    --记录创建的支付状态
    --Key sOutTradeNo Value bSuccess
    Payment.paymentStatus={}

end


function Payment:CreatePayment(keys) 
     Payment:CreatePaymentRequest(keys.PlayerID,keys.id,keys.type,keys.tier)
end 


--获取付款二维码
function Payment:CreatePaymentRequest(sPlayerID,sEventID,sPaymentType,sTier)

    local request = CreateHTTPRequestScriptVM("GET", server_address .. "createpayment")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));

    local nPlayerSteamId = PlayerResource:GetSteamAccountID(sPlayerID)
    --交易号从lua生成
    local sOutTradeNo =  tostring(nPlayerSteamId).."_"..GetServerDateTimeStr().."_"..RandomInt(10000, 99999)
    request:SetHTTPRequestGetOrPostParameter("player_steam_id",tostring(nPlayerSteamId));
    request:SetHTTPRequestGetOrPostParameter("out_trade_no",sOutTradeNo);
    request:SetHTTPRequestGetOrPostParameter("payment_type",sPaymentType);
    request:SetHTTPRequestGetOrPostParameter("tier",sTier);

    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then
             print("CreatePayment, Success"..result.StatusCode)
             local hPlayer = PlayerResource:GetPlayer(sPlayerID)
             if not hPlayer then return end
             CustomGameEventManager:Send_ServerToPlayer(hPlayer, "CreatePayment", {
                id = sEventID,
                url = result.Body
             })
             --启动定时任务 轮询付款
             --如果轮询到结果 刷新前台付款结束
             Timers:CreateTimer({
                useGameTime = false,
                endTime = 2,
                callback = 
                  function()

                     if Payment.paymentStatus[sOutTradeNo] ==nil then
                        Payment.paymentStatus[sOutTradeNo]={}
                        --重试次数
                        Payment.paymentStatus[sOutTradeNo].nRetryTime=0
                        --支付是否成功
                        Payment.paymentStatus[sOutTradeNo].bSuccess=false
                     end

                     if Payment.paymentStatus[sOutTradeNo].bSuccess==false then
                        Payment:QueryPayment(sPlayerID,sOutTradeNo)
                     end
                     
                     --支付成功 或者超过轮询次数
                     if Payment.paymentStatus[sOutTradeNo].bSuccess or Payment.paymentStatus[sOutTradeNo].nRetryTime>700 then
                        return nil
                     else
                        Payment.paymentStatus[sOutTradeNo].nRetryTime = Payment.paymentStatus[sOutTradeNo].nRetryTime + 1
                        return 3
                     end
                  end
              })
        else
            print("CreatePayment, Fail:"..result.Body)       
        end
    end)
end


--查询付款
--1购买小兔币成功 2购买Pass成功 3等待付款 4无记录 5失败
function Payment:QueryPayment(sPlayerID, sOutTradeNo)
    
    local nPlayerSteamId = PlayerResource:GetSteamAccountID(sPlayerID)
    local request = CreateHTTPRequestScriptVM("GET", server_address .. "querypayment")
    request:SetHTTPRequestHeaderValue("dedicated_server_key",GetDedicatedServerKey(GetDedicatedServerKeyV2("1"))..GetDedicatedServerKeyV2(GetDedicatedServerKey("2"))..GetDedicatedServerKey("3"));
    request:SetHTTPRequestGetOrPostParameter("out_trade_no",sOutTradeNo);

    request:Send(function(result)
        if result.StatusCode == 200 and result.Body~=nil then   
            local body = JSON:decode(result.Body)
            if body ~= nil then
                --PrintTable(body)
                --如果成功
                
                if body.type=="2" then                    
                   --刷新钱
                   local sPlayerName=PlayerResource:GetPlayerName(sPlayerID)
                   local heroName=PlayerResource:GetSelectedHeroName(sPlayerID)
                   Notifications:BottomToAll({hero = heroName, duration = 5, continue = true})
                   Notifications:BottomToAll({text = sPlayerName.." ", duration = 5, continue = true})
                   Notifications:BottomToAll({text = "#taobao_thank_note", duration = 5, style = {color = "Orange"}, continue = true})
                   GrantExtraLife()  --给与队伍额外生命
                   local keys={playerId=sPlayerID,vipLevel=2}  --传回的是等级
                   GameRules:GetGameModeEntity().CHoldoutGameMode.vipMap[nPlayerSteamId].level=2
                   CustomNetTables:SetTableValue( "vipMap", tostring(nPlayerSteamId), {level=2,validate_date=body.validate_date} )

                   --付款成功 报送前台
                   local hPlayer = PlayerResource:GetPlayer(sPlayerID)
                   CustomGameEventManager:Send_ServerToPlayer(hPlayer, "PaymentSuccess", {type=body.type})
                   Payment.paymentStatus[sOutTradeNo].bSuccess=true
                end

                if body.type=="3" then
                    print("Payment Pending"..sOutTradeNo)
                end
                if body.type=="4" then
                     print("Payment NoRecord"..sOutTradeNo)
                end
                if body.type=="5" then
                     print("Payment Fail"..sOutTradeNo)
                end
            end
        else
            print("SubscribePassByCoins, Fail:"..result.StatusCode)    
        end
    end)
end