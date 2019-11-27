"use strict";


function ShowRoundTitle(keys) {
    //$.Msg( "OnPlayerEnteredZone"+keys.roundTitle );
    Game.EmitSound("Dungeon.Stinger07");
    $("#RoundTitleToastPanel").SetHasClass("Visible", true);
    $("#RoundTitleLabel").text = $.Localize(keys.roundTitle);
    $.Schedule(5.0, HideRoundTitle);
}

function HideRoundTitle() {
    $("#RoundTitleToastPanel").SetHasClass("Visible", false);
}


GameEvents.Subscribe("ShowRoundTitle", ShowRoundTitle);
