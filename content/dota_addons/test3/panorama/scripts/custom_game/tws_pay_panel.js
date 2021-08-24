const createPaymentRequest = CreateEventRequestCreator("CreatePayment");

function ClosePassPanel(){

    $("#PassPanel").AddClass("Hidden")
}

function UpdatePassInfo(){
    var playerId = Game.GetLocalPlayerInfo().player_id;

    if ( $("#PassUntilLabel") )
    {
        
        var playerId = Players.GetLocalPlayer();
        var steam_id = Game.GetPlayerInfo(playerId).player_steamid;

        var vipValidDateUTC = CustomNetTables.GetTableValue("vipMap", "" + ConvertToSteamId32(steam_id)).validate_date;
        if (vipValidDateUTC != null && vipValidDateUTC != "") {

            var utcDate = new Date(vipValidDateUTC.replace(/-/g, '/'));
            var localOffset = (new Date()).getTimezoneOffset() * 60000;
            var localDate = new Date(utcDate.getTime() - localOffset);
            var localDateStr = getFormatDateStr(localDate);
            $("#PassUntilLabel").text = $.Localize("#pass_until") + localDateStr;
        }
        
    }
}

//切换支付弹窗的显示状态，参数有 "closed" | "loading" | "html"
function SetPaymentWindowStatus(state) {
    if ($("#PaymentWindow")==undefined)
    {
        return;
    }
    const hid = $("#PaymentWindow").BHasClass("Hidden");
    const visible = state !== "closed";
    $("#PaymentWindow").SetHasClass("Hidden", !visible);
    GameEvents.SendCustomGameEventToServer("payments:window", { visible });
    $("#PaymentWindowLoader").visible = state === "loading";
    $("#PaymentWindowHTML").visible = state === "html";
    $("#PaymentWindowWaitPaypal").visible = state === "wait_paypal";

    const isError = typeof state === "object";
    $("#PaymentWindowError").visible = isError;
    if (isError) {
        $("#PaymentWindow").SetHasClass("Hidden", hid);
        $("#PaymentWindowErrorMessage").text = state.error;
    }
}

function GetPaymentQRCode(tier,type) {

    //打开支付弹窗
    SetPaymentWindowStatus("loading");
    
    paymentWindowUpdateListener = createPaymentRequest({ type:type, tier:tier }, (response) => {   

        if (response.url == null || response.url == "") {
            SetPaymentWindowStatus({ error: response.error || "Unknown error" });
            return;
        } 

        if (type=="wechat" || type=="alipay")
        {
            //渲染弹窗
            $("#PaymentWindowHTML").SetURL(response.url);
            //延迟0.5 取消loading页面
             $.Schedule(1.5, () => {
                SetPaymentWindowStatus("html");
            });
        }
        
        if (type=="paypal")
        {
            //使用内置浏览器支付
            SetPaymentWindowStatus("wait_paypal");
            $.DispatchEvent( 'ExternalBrowserGoToURL',response.url );
        }
    });
}



function ChangePaymentType(type) {
   
   $("#PaymentTier").type=type;
   $("#PaymentTierContainer").RemoveClass("Hidden");
   $("#SelectPaymentLabel").AddClass("Hidden");
}


function PaymentSuccess(keys) {
  
  SetPaymentWindowStatus("closed");
  $("#PassPanel").AddClass("Hidden");
  UpdatePassInfo();

}


(function()
{   
    GameEvents.Subscribe( "UpdatePassInfo", UpdatePassInfo ); //返回订阅通行证信息
    GameEvents.Subscribe( "PaymentSuccess", PaymentSuccess ); //关闭支付页面
    if ($("#SelectPaymentLabel"))
    {
        $("#SelectPaymentLabel").RemoveClass("Hidden");
    }
    UpdatePassInfo();
})();
