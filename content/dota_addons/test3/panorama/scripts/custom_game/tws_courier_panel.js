"use strict";

var couriersList = ["beetle_bark","beetle_jaws","dark_moon"]





(function () {

    for (var i = 0; i<=couriersList.length-1;i++) {
        
        var courierCode = couriersList[i];
        var courierPanel = $.CreatePanel("Panel", $("#CourierPanelContainer"), courierCode);

        courierPanel.BLoadLayoutSnippet("CourierItem");
        courierPanel.FindChildTraverse("courier_item_label").text = $.Localize(courierCode);
        courierPanel.FindChildTraverse("courier_item_image").SetImage("file://{resources}/images/custom_game/couriers/" + courierCode + ".png");
        
        courierPanel.FindChildTraverse("courier_item_radio").SetPanelEvent("onactivate", RecordSelect(courierCode));
        courierPanel.FindChildTraverse("courier_item_radio").group = "courierRadios"

    }
    
})();