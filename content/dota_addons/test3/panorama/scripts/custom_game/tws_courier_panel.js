"use strict";



function ShowCourierConfirmTooltip() {
  if ($("#CourierConfirmButton").enabled == false) {
       $.DispatchEvent("DOTAShowTitleTextTooltip", $("#CourierConfirmButton"), "#save_button_title", "");
  }
}

function HideCourierConfirmTooltip(index) {
  if ($("#CourierConfirmButton").enabled == false) {
       $.DispatchEvent("DOTAHideTitleTextTooltip", $("#CourierConfirmButton"));
  }
}


function CourierConfirm()  //向Lua传递确认信息
{
    var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
    var courierPanelHub = $("#CourierPanelHub");

    GameEvents.SendCustomGameEventToServer("ConfirmCourier", {playerId: playerId, courierCode: courierPanelHub.courierCode });

    var courierPanelMain = courierPanelHub.FindChildTraverse("CourierPanelMain");
    //隐藏面板    
    courierPanelMain.SetHasClass("hidden", true);
}


function CourierCancle()  //向Lua传递确认信息
{
    //隐藏面板  
    var courierPanelHub = $("#CourierPanelHub"); 
    var courierPanelMain = courierPanelHub.FindChildTraverse("CourierPanelMain");
    courierPanelMain.SetHasClass("hidden", true);
}




(function () {
    
})();