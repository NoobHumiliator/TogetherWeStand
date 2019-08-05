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
    var width = Game.GetScreenWidth()
    var height = Game.GetScreenHeight()
    //3.55555 32:9
    //2.33333 21:9
    //1.777 16:9
    //1.6   16:10
    //1.33  4:3
    var radio = width / height
    if (3.0 <= radio) {
        $("#triggerButtonPanel").style.position = "2920px 1020px 0"
    }
    if (2.0 <= radio < 3.0) {
        $("#triggerButtonPanel").style.position = "1940px 1020px 0"
    }
    if (1.7 <= radio < 2.0) {
        $("#triggerButtonPanel").style.position = "1500px 1020px 0"
    }
    if (1.5 <= radio && radio < 1.7) {
        $("#triggerButtonPanel").style.position = "1380px 1020px 0"
    }
    if (radio < 1.5) {
        $("#triggerButtonPanel").style.position = "1050px 1020px 0"
    }

    $.DispatchEvent("DOTAShowTitleTextTooltip", $("#triggerButtonPanel"), "#spell_trigger_notice_title", "#spell_trigger_notice_detail");
}

function HideTooltip() {
    $.DispatchEvent("DOTAHideTitleTextTooltip", $("#triggerButtonPanel"));
}

(function () {
    FixSpellShopPosition();
    $.Schedule(7.0, HideTooltip);
})();


function OnTestButtonPressed() {

    //var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
    ShowMainBlock();
}

Game.AddCommand("+CustomGameTestButton", OnTestButtonPressed, "", 0);