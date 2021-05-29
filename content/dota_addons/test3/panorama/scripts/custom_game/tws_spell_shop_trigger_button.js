"use strict";

function ShowMainBlock() {
    var button = $("#triggerButton");
    var block = button.GetParent().GetParent().GetParent().FindChild("spellShop").FindChild("mainShop");
    if (block.invisible == null || block.invisible == true) {
        block.invisible = false;
        block.SetHasClass("Hidden", false);
        Game.EmitSound("Shop.PanelUp");
    }
    else {
        block.invisible = true;
        block.SetHasClass("Hidden", true);
        Game.EmitSound("Shop.PanelDown");
    }
    HideTooltip()
}

function FixSpellShopPosition() {
    var width = Game.GetScreenWidth();
    var height = Game.GetScreenHeight();
    var radio = width / height;

    if (radio < 1.5) {
        //1.33  4:3
        $("#triggerButtonPanel").style.position = "150px 0px 0";
    } else if (radio < 1.7) {
        //1.6   16:10
        $("#triggerButtonPanel").style.position = "150px 0px 0";
    } else if (radio < 2.0) {
        //1.777 16:9
        $("#triggerButtonPanel").style.position = "150px 0px 0";
    } else if (radio < 3.0) {
        //2.33333 21:9
        $("#triggerButtonPanel").style.position = "150px 0px 0";
    } else {
        //3.55555 32:9
        $("#triggerButtonPanel").style.position = "150px 0px 0";
    }

    $.DispatchEvent("DOTAShowTitleTextTooltip", $("#triggerButtonPanel"), "#spell_trigger_notice_title", "#spell_trigger_notice_detail");
}

function HideTooltip() {
    $.DispatchEvent("DOTAHideTitleTextTooltip", $("#triggerButtonPanel"));
}

function UpdateAbilityList(keys) {
    var playerId = keys.playerId
    var playerHeroIndex = Players.GetPlayerHeroEntityIndex(playerId);
    $("#spell_shop_hotkey").text = $.Localize("#spell_shop_points") + Entities.GetAbilityPoints(playerHeroIndex) + "(F6)";
}


(function () {
    FixSpellShopPosition();
    $.Schedule(7.0, HideTooltip);
    GameEvents.Subscribe("UpdateAbilityList", UpdateAbilityList);
})();


function OnTestButtonPressed() {

    //var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
    ShowMainBlock();
}

Game.AddCommand("+CustomGameTestButton", OnTestButtonPressed, "", 0);