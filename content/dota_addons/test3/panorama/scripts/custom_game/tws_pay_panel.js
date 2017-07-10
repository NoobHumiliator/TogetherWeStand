"use strict";


var paymentId=null; //PayPal的付款ID 也是vip_register表的code

function OpenPayLink(payMethod){

    var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
    var steam_id = Game.GetPlayerInfo(playerId).player_steamid;
    steam_id = ConvertToSteamId32(steam_id);
    
    $( "#PayLinkPanel" ).SetHasClass("hidden",false)
    $( "#PayLinkPanel" ).SetHasClass("PopupPanel",true)
    $( "#PayLinkMask" ).SetHasClass("hidden",false); //蒙版显示出来
    $( "#PayLinkInfo" ).SetHasClass("hidden",true); //隐藏二维码
    $( "#TaobaoInfo" ).SetHasClass("hidden",true); //隐藏淘宝

    PayPanelContainerCloseButtonActive(); //隐藏付款面板

    if (payMethod=="PayPal")
    {    
        $.AsyncWebRequest('http://191.101.226.126:8005/applypaypal?steam_id='+steam_id,  //向服务器请求PayPal的付款链接
        {
            type: 'GET',
            success: function(resultJson) {
                var result = JSON.parse(resultJson);
                var url=result.url;
                var qr64str=result.img_str;
                paymentId=result.paymentId;  //全局变量，存一个最新的付款ID
                var urlReplace=url.replace("&","%26") //传参转义
                $( "#PayPalQRCodeHtml" ).SetURL("http://191.101.226.126:8005/urltoqrcode?url="+urlReplace);
                

                var urlHref=url.replace("&","&amp;") //href转义
                $( "#PayLinkInfo").BCreateChildren("<Label html='true' id='PayPalUrl' text='&lt;a href=&quot;"+urlHref+"&quot;&gt;"+urlHref+"&lt;a&gt;'/>")

                $( "#PayLinkMask" ).SetHasClass("hidden",true); //蒙版隐藏起来
                $( "#PayLinkInfo" ).SetHasClass("hidden",false); //显示二维码
                $( "#MousePanningImage" ).SetHasClass("hidden",true); //隐藏不知道什么的导航条

                $.Schedule(4,HasFinishedPay);
            }
        });  
    }

    if (payMethod=="TaoBao")
    {    

        $( "#PayLinkMask" ).SetHasClass("hidden",true); //蒙版隐藏起来
        $( "#PayLinkInfo" ).SetHasClass("hidden",true); //隐藏Paypal
        $( "#TaobaoInfo" ).SetHasClass("hidden",false); //显示淘宝
        var taobaoUrl="https://item.taobao.com/item.htm?id=550725086992";
        $( "#TaobaoInfo").BCreateChildren("<Label html='true' id='PayPalUrl' text='&lt;a href=&quot;"+taobaoUrl+"&quot;&gt;"+taobaoUrl+"&lt;a&gt;'/>")
    }
}


function PayLinkInfoCloseButtonActive(){
    $( "#PayLinkPanel" ).SetHasClass("hidden",true); //隐藏弹出面板
}

function PayPanelContainerCloseButtonActive(){

    $( "#PayPanelContainer" ).SetHasClass("hidden",true); //隐藏弹出面板

}

function HasFinishedPay() {
   
    if (paymentId==null)
    {
        return;
    }
    $.AsyncWebRequest('http://191.101.226.126:8005/querypayment?paymentId='+paymentId,  //向服务器请求PayPal的付款链接
    {
            type: 'GET',
            success: function(result) {
                if (result=="success") //如果付款成功
                {
                    PayLinkInfoCloseButtonActive(); //关了两个面板
                    PayPanelContainerCloseButtonActive();
                    var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
                    GameEvents.SendCustomGameEventToServer( "ReceiveVipQureySuccess", {playerId:playerId,level:2} ); //默认2级别VIP
                    paymentId=null; //将paymentID清空 结束循环
                }
            }
    });  

    $.Schedule(0.6,HasFinishedPay);
}


(function()
{


})();

