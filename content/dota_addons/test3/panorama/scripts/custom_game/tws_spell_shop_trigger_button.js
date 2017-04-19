"use strict";

function ShowMainBlock()
{
	var button = $( "#triggerButton" );
	var block=button.GetParent().GetParent().GetParent().FindChild("spellShop").FindChild("mainShop");
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

function FixSpellShopPosition()
{
    var width =Game.GetScreenWidth()
    var height =Game.GetScreenHeight()
    //1.777 16:9
    //1.6   16:6
    //1.33  4:3
    $.Msg(width/height)
    var radio=width/height
    if (1.7<radio)
    {
    	$("#triggerButtonPanel").style.position="1500px 1020px 0"
    }
	if ( 1.5<radio&&radio<1.7)
    {
    	$("#triggerButtonPanel").style.position="1300px 1020px 0"
    }
    if ( radio<1.4 )
    {

    	$("#triggerButtonPanel").style.position="1050px 1020px 0"
    }
}


(function()
{

     FixSpellShopPosition();

})();


function OnTestButtonPressed()
{
	$.Msg( "Test button pressed." );
	//var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	ShowMainBlock();
}

Game.AddCommand( "+CustomGameTestButton", OnTestButtonPressed, "", 0 );