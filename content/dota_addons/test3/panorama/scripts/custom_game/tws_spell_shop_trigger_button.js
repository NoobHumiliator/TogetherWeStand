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


})();


function OnTestButtonPressed()
{
	$.Msg( "Test button pressed." );
	//var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	ShowMainBlock();
}

Game.AddCommand( "+CustomGameTestButton", OnTestButtonPressed, "", 0 );