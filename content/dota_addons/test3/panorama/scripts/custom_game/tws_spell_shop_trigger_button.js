"use strict";

function ShowMainBlock()
{
	var button = $( "#triggerButton" );
	var block=button.GetParent().GetParent().FindChild("spellShop").FindChild("mainShop");
	if (block.invisible==null || block.invisible==true)
	{
	 block.invisible=false;
     block.SetHasClass("Hidden", false);
     Game.EmitSound("Shop.PanelUp");
	}
	else
	{
     block.invisible=true;
     block.SetHasClass("Hidden", true);
     Game.EmitSound("Shop.PanelDown");
	}
}


(function()
{
	$.Schedule(1.5, ajustTriggerButton);

})();

function ajustTriggerButton()
{
    var minimapBlock = GameUI.hub.FindChildTraverse("minimap_block");
    $.Msg(minimapBlock.contentwidth)
    var button = $("#triggerButton" );
    button.y=minimapBlock.contentwidth;
    if (minimapBlock.BHasClass ("MinimapExtraLarge"))
    {
    	$.Msg("mini map has extra large class.")
    }
    else
    {
    	$.Msg("mini map has no large class.")
    }
    $.Schedule(1.5, ajustTriggerButton);
}


function OnTestButtonPressed()
{
	$.Msg( "Test button pressed." );
	//var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	ShowMainBlock();
}

Game.AddCommand( "+CustomGameTestButton", OnTestButtonPressed, "", 0 );