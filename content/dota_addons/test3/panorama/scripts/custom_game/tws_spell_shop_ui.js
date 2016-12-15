"use strict";

var config = {
	"cmHeroesGroup" : "file://{resources}/layout/custom_game/tws_heroes_group.xml",
	"radiobutton" : "file://{resources}/layout/custom_game/tws_radiobutton.xml",
	"cmSelectionPlayer" : "file://{resources}/layout/custom_game/tws_hero_ability_list.xml",
	"heroAbilityList" : "file://{resources}/layout/custom_game/tws_hero_ability_list.xml",
	"playerAbilityList" : "file://{resources}/layout/custom_game/tws_player_ability_list.xml",
	"adPlayerLeft" : "file://{resources}/layout/custom_game/hero_selection_ad_player_left.xml",
	"adPlayerRight" : "file://{resources}/layout/custom_game/hero_selection_ad_player_right.xml",
};

var unsellableAbility = {
	"shredder_chakram" : true,
	"witch_doctor_death_ward" : true,
	"meepo_divided_we_stand" : true,
	"broodmother_spin_web" : true,
	"shredder_chakram_2" : true,
	"treant_eyes_in_the_forest" : true,
	"wisp_tether_break" : true
};

//卖技能的面板中不显示这些技能
var hideAbility = {
	"damage_counter" : true,
	"attribute_bonus" : true,
	"keeper_of_the_light_illuminate_end" : true,
	"keeper_of_the_light_spirit_form_illuminate" : true,
	"morphling_morph_replicate" : true,
	"shredder_return_chakram":  true,
	"elder_titan_return_spirit" :true,
	"phoenix_icarus_dive_stop": true,
	"phoenix_sun_ray_stop":  true,
	"phoenix_launch_fire_spirit" : true,
	"abyssal_underlord_cancel_dark_rift":  true,
	"alchemist_unstable_concoction_throw":  true,
	"naga_siren_song_of_the_siren_cancel":  true,
	"rubick_telekinesis_land":  true,
	"bane_nightmare_end":  true,
	"ancient_apparition_ice_blast_release":  true,
	"lone_druid_true_form_druid" : true,
	"shredder_return_chakram_2" : true,
	"nyx_assassn_unburrow" : true,
	"morphling_morph" : true
};


var noReturnAbility = {    //不退回升级点数的技能
    "troll_warlord_whirling_axes_ranged" : true,
    "troll_warlord_whirling_axes_melee" : true,
    "lone_druid_savage_roar_bear" : true,
    "phoenix_sun_ray_toggle_move" : true,
    "morphling_hybrid" : true,
    "morphling_morph":true,
    "morphling_morph_agi":true
}



////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



var Titles_HeroesGroups = [$.Localize("#str"), $.Localize("#agi"), $.Localize("#int")];

var Text_StateAction = [ "CHOOSE", "BAN", "PICK" ];


var CurrentHero = ["","","","","","","","","",""]


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function SetPanelText( parentPanel, childPanelId, text ) {
	if ( !parentPanel )
	{
		return;
	}

	var childPanel = parentPanel.FindChildInLayoutFile( childPanelId );
	if ( !childPanel )
	{
		return;
	}

	childPanel.text = text;
}

function Update_Heroes_Table()
{
	var container = $( "#heroesTableStrAgi" );
	var container_int= $("#heroesTableInt");

	//$.Msg(container);
	for (var row = 1; row <= 2; row++)
	{ 
	 _cm_Heroes_UpdateRow( container, row );
	}
	 _cm_Heroes_UpdateRow_int(container_int);
}

function First()
{
	var container = $( "#heroesTableStrAgi" );
	var container_int= $("#heroesTableInt");
	$.Msg(container);
}



function _cm_Heroes_UpdateRow( container, row )
{
	var parentPanelId = "_heroes_row_" + row;
	//var parentPanel = null;
	var parentPanel = container.FindChild( parentPanelId );
	if ( !parentPanel )
	{
		parentPanel = $.CreatePanel( "Panel", container, parentPanelId );    //创建英雄组的panel
		parentPanel.BLoadLayout( config.cmHeroesGroup, false, false );       //英雄组的panel布局
		parentPanel.SetHasClass( "cmHeroesRow", true );
	}

	var className = "cmHeroesGroupTitle_" + row;
	var groupNamePanel = parentPanel.FindChildInLayoutFile( "GroupName" );
	// SetPanelText( parentPanel, "GroupName", Titles_HeroesGroups[ row - 1 ] );
	groupNamePanel.text = Titles_HeroesGroups[ row - 1 ];              //设置group name
	groupNamePanel.SetHasClass( className, true );                     //设置class

	var groupTable = parentPanel.FindChildInLayoutFile( "GroupTable" );

	for ( var i = 1; i <= 2; i++ )
	{
		var groupName = ( ( row - 1 ) * 2 ) + i;
		var groupKV = CustomNetTables.GetTableValue( "heroes", groupName );

		var groupPanelId = "_heroes_group_" + groupName;
		var groupPanel = groupTable.FindChild( groupPanelId );
		if ( !groupPanel )
		{
			groupPanel = $.CreatePanel( "Panel", groupTable, groupPanelId );
			groupPanel.SetHasClass( "cm_heroes_group", true );
		}

		_cm_Heroes_UpdateGroup( groupKV, groupPanel, groupName);
	}
}


function _cm_Heroes_UpdateRow_int( container)
{
	var parentPanelId = "_heroes_row_3";
	var parentPanel = container.FindChild( parentPanelId );
	if ( !parentPanel )
	{
		parentPanel = $.CreatePanel( "Panel", container, parentPanelId );    //创建英雄组的panel
		parentPanel.BLoadLayout( config.cmHeroesGroup, false, false );       //英雄组的panel布局
		parentPanel.SetHasClass( "cmHeroesRow", true );
	}

	var className = "cmHeroesGroupTitle_3";
	var groupNamePanel = parentPanel.FindChildInLayoutFile( "GroupName" );
	// SetPanelText( parentPanel, "GroupName", Titles_HeroesGroups[ row - 1 ] );
	groupNamePanel.text = Titles_HeroesGroups[2];              //设置group name
	groupNamePanel.SetHasClass( className, true );             //设置class

	var groupTable = parentPanel.FindChildInLayoutFile( "GroupTable" );

	for ( var i = 1; i <= 2; i++ )
	{
		var groupName = 4 + i;
		var groupKV = CustomNetTables.GetTableValue( "heroes", groupName );

		var groupPanelId = "_heroes_group_" + groupName;
		var groupPanel = groupTable.FindChild( groupPanelId );
		if ( !groupPanel )
		{
			groupPanel = $.CreatePanel( "Panel", groupTable, groupPanelId );
			groupPanel.SetHasClass( "cm_heroes_group", true );
		}

		_cm_Heroes_UpdateGroup( groupKV, groupPanel, groupName);
	}
}




function _cm_Heroes_UpdateGroup( groupKV, groupPanel, groupName)
{
	var groupContainerId = "_heroes_group_container_" + groupName;
	var groupContainer = groupPanel.FindChild( groupContainerId );
	if ( !groupContainer )
	{
		groupContainer = $.CreatePanel( "Panel", groupPanel, groupContainerId );
		groupContainer.SetHasClass( "cm_heroes_group_container", true );
		groupContainer.SetHasClass( "hBlock", true );
	}

	for ( var heroId in groupKV )
	{
		for ( var name in groupKV[ heroId ] )
		{
			var heroPanelId = "_heroes_hero_" + name;
			var heroPanel = groupContainer.FindChild( heroPanelId );
			if ( !heroPanel )
			{
				heroPanel = $.CreatePanel( "Panel", groupContainer, heroPanelId );
				heroPanel.BLoadLayout( config.radiobutton, false, false );
				heroPanel.SetHasClass( "cm_heroes_heropanel", true );
			}		

			_cm_Heroes_UpdateHero( groupKV, heroPanel, groupName, heroId, name);
	 	}
	}
}

function _cm_Heroes_UpdateHero( groupKV, heroPanel, groupName, heroId, name)
{
	var rButton = heroPanel.FindChildInLayoutFile( "RadioButton" );
	rButton.group = "Heroes";
	rButton.SetHasClass( "hBlock", true );

	var isEnabled = groupKV[ heroId ][ name ];
	if ( isEnabled == 0 )
	{
		rButton.enabled = false;
	}

	rButton.data = {
		heroName: name,
		heroId: heroId,
		heroGroup: groupName
		// heroRow: row
	};

	var pID = Game.GetLocalPlayerInfo().player_id;     //玩家ID
	rButton.SetPanelEvent( "onselect", PreviewHero( rButton.data ) );   //保存下选择的英雄内容
	var childImage = heroPanel.FindChildInLayoutFile( "RadioImage" );
	childImage.heroname = "npc_dota_hero_" + name;
}



function Hero_Ability_List_Update(heroName,playerId,isButtonEvent)
{

	var container= $("#buyPanel")
	if (isButtonEvent)
	 {
	  ChangeToBuyPanel(false);
     }
	var parentPanelId = "_ability_list"
	var parentPanel = container.FindChild( parentPanelId );
	if ( !parentPanel )
	{
		parentPanel = $.CreatePanel( "Panel", container, parentPanelId );    //英雄技能的Panel
		parentPanel.BLoadLayout( config.heroAbilityList, false, false );     //英雄组的panel布局
		parentPanel.AddClass( "player" );
	}

	var childImage = parentPanel.FindChildInLayoutFile( "HeroImage" );
	var abilityList =  parentPanel.FindChildInLayoutFile( "Abilities" );

	if ( heroName != "" )
	{
		childImage.heroname = "npc_dota_hero_" + heroName;            //英雄头像
		var slotNumber=0;
		for (var abilitySlot in CustomNetTables.GetTableValue( "abilities", heroName ))
		{
			slotNumber=slotNumber+1;
		}
		if (!abilityList.maxslot || abilityList.maxslot<slotNumber )
		{
           abilityList.maxslot=slotNumber;
		}
        for ( var slot = 1; slot <= abilityList.maxslot; slot++ )                       //先全部隐藏起来
	    {
		 InvisibleAbilityList(abilityList,slot);
	    }
	    for ( var slot = 1; slot <= slotNumber; slot++ )                                //英雄技能列表
	    {
		  UpdateAbility( abilityList, heroName, slot ,playerId);
	    }
	}

}


function InvisibleAbilityList(abilityList,slot)
{
     var abButtonId = "_ability_new_"+ slot;
     var abButton = abilityList.FindChild( abButtonId );
     if ( abButton )
	 {
		abButton.SetHasClass( "hidden", true );
	 }
}


function UpdateAbility(abilityList,heroName,slot,playerId)
{
	var abButtonId = "_ability_new_"+ slot;
	var abButton = abilityList.FindChild( abButtonId );
	if ( !abButton )
	{
		abButton = $.CreatePanel( "Button", abilityList, abButtonId );
	}
	abButton.SetHasClass( "hidden", false );
    
	var abPanelId = "_ability_image_"+ slot;
	var abPanel = abButton.FindChild( abPanelId );
	var abCostLabelId = "_ability_cost_"+ slot;
	var abCostLabel = abButton.FindChild( abCostLabelId );
	var abilityName=CustomNetTables.GetTableValue( "abilities", heroName )[ slot ];
	if ( !abPanel )
	{
		abPanel = $.CreatePanel( "DOTAAbilityImage", abButton, abPanelId );
		abPanel.SetHasClass( "hBlock", true );
		abPanel.SetHasClass( "vBlock", true );
		var costInit=1;
		abPanel.data = {
			abilityName: abPanel.abilityname,
			heroName: heroName,
			position: slot,
			playerId: playerId,
			abilityCost: 1,
			enough: false,
			reachFive:false
		}

		abButton.SetPanelEvent( "onmouseover", ShowAbilityTooltip( abPanel ) );
		abButton.SetPanelEvent( "onmouseout", HideAbilityTooltip( abPanel ) );
		abButton.SetPanelEvent( "onactivate", AddAbility( abPanel ) );
        abCostLabel = $.CreatePanel( "Label", abButton, abCostLabelId );
        ResetPanelData(abPanel,abCostLabel,abilityName,heroName,playerId);
	}
	else    //更新技能
	{
        ResetPanelData(abPanel,abCostLabel,abilityName,heroName,playerId);
	}
}

function ResetPanelData(abPanel,abCostLabel,abilityName,heroName,playerId)
{
	abPanel.abilityname=abilityName; 
    abPanel.data.abilityName=abilityName; 
    abPanel.data.heroName=heroName;
    var abilityCost=GetAbilityCost(abilityName);
    abCostLabel.text=abilityCost;
    abPanel.data.abilityCost=abilityCost;
    if (GetPlayerAbilityNumber(playerId)==5)
    {
       abPanel.data.reachFive=true;
    }
    if (!AbilityPointEnough(abilityCost,playerId))      //技能点不够
    {
        abPanel.data.enough=false;
        abPanel.SetHasClass( "notEnoughDark", true );
    }
    else
    {
        abPanel.data.enough=true;
        abPanel.SetHasClass( "notEnoughDark", false );
    }
    CheckAbilityButtonAvailable(abPanel.GetParent(),abilityName,playerId);
}




function GetAbilityCost (abilityName)
{
	  var abilityCost=1;
	  var abcost=CustomNetTables.GetTableValue( "abilitiesCost", abilityName);
      if (abcost==null)
       {
         abilityCost=1;
       }
      else
       {
        abilityCost=abcost[1];
       }
      return   abilityCost;
}

function AbilityPointEnough(abilityCost,playerId)
{
       var playerHeroIndex=Players.GetPlayerHeroEntityIndex(playerId) ;
       if (abilityCost<=Entities.GetAbilityPoints( playerHeroIndex ))
       {
       	return true;
       }
       {
       	return false;
       }
}


function CheckAbilityButtonAvailable (Button,abilityName,playerId)
{
	var playerHeroIndex=Players.GetPlayerHeroEntityIndex(playerId) ;
	var abilityIndex=Entities.GetAbilityByName(playerHeroIndex, abilityName );
	if (abilityIndex==-1)
     {
         Button.enabled = true; 
     }
    else
     {
         Button.enabled = false;         
     }
     if (GetPlayerAbilityNumber(playerId)>=6)
     {
         Button.enabled = false; 
     }
}

function InvisiblePlayerAbilityList(abilityList,slot)
{
     var abButtonId = "player_ability_"+ slot;
     var abButton = abilityList.FindChild( abButtonId );
     if ( abButton )
	 {
		abButton.SetHasClass( "hidden", true );
	 }
}

function PlayerAbilityListUpdate(playerId)
{
	var container= $("#sellPanel");
	var parentPanelId = "player_ability_list";
	var parentPanel = container.FindChild( parentPanelId );
	if ( !parentPanel )
	{
		parentPanel = $.CreatePanel( "Panel", container, parentPanelId );    //英雄技能的Panel
		parentPanel.BLoadLayout( config.playerAbilityList, false, false );     //英雄组的panel布局
		parentPanel.AddClass( "player" );
		//container.SetHasClass("hidden", true);
	}

	var childImage = parentPanel.FindChildInLayoutFile( "PlayerImage" );
	var playerAbilityList =  parentPanel.FindChildInLayoutFile( "PlayerAbilities" );
	var playerdata = Game.GetPlayerInfo(playerId);
	childImage.steamid = playerdata.player_steamid;                        //玩家的SteamId用来显示头像
	var playerHeroIndex=Players.GetPlayerHeroEntityIndex(playerId) ;
	var slotNumber=0;
	if (playerAbilityList.maxslot>=1)
	{
	   for ( var slot = 1; slot <= playerAbilityList.maxslot; slot++ )             //先全部隐藏起来
	   {
		 InvisiblePlayerAbilityList(playerAbilityList,slot);
	   }
	}
    for (var i = 0 ; i <= 20; i++) 
    {
       var ability=Entities.GetAbility(playerHeroIndex,i);
       var abilityName=Abilities.GetAbilityName(ability);
       if(abilityName!="" && hideAbility[abilityName]!=true&&abilityName.substring(0,14)!="special_bonus_") //天赋技能默认隐藏
        {
           slotNumber=slotNumber+1;
           UpdatePlayerAbility(playerAbilityList,slotNumber,abilityName,playerId);
        }
    }  
    if  (!playerAbilityList.maxslot || playerAbilityList.maxslot<slotNumber)
    {
         playerAbilityList.maxslot=slotNumber;
    }
}

function GetPlayerAbilityNumber (playerId)
{
	var abilityNumber=0;
	var playerHeroIndex=Players.GetPlayerHeroEntityIndex(playerId) ;
    for (var i = 0 ; i <= 20; i++) 
    {
       var abilityName=Abilities.GetAbilityName(Entities.GetAbility(playerHeroIndex,i));
       if(abilityName!=""&& hideAbility[abilityName]!=true&&abilityName.substring(0,14)!="special_bonus_")
        {
           abilityNumber=abilityNumber+1;
        }
    }  
    return abilityNumber;
}






function UpdatePlayerAbility (abilityList,slot,abilityName,playerId)
{
	var abButtonId = "player_ability_"+ slot;
    var abButton = abilityList.FindChild( abButtonId );
	if ( !abButton )
	{
		abButton = $.CreatePanel( "Button", abilityList, abButtonId );
	}
	abButton.SetHasClass( "hidden", false );
	var abPanelId = "player_ability_image_"+ slot;
	var abPanel = abButton.FindChild( abPanelId );
	var sellCostLabelId = "ability_sell_cost_"+ slot;
	var sellCostLabel = abButton.FindChild( sellCostLabelId );
	if ( !abPanel )
	{
		abPanel = $.CreatePanel( "DOTAAbilityImage", abButton, abPanelId );
		abPanel.SetHasClass( "hBlock", true );
		abPanel.SetHasClass( "vBlock", true );
		abPanel.data = {
			abilityName: abilityName,
			playerId: playerId,
			abilityCost:1,
			abilityLevel:1,
		}
		abButton.SetPanelEvent( "onmouseover", ShowAbilityTooltip( abPanel ) );
		abButton.SetPanelEvent( "onmouseout", HideAbilityTooltip( abPanel ) );
		abButton.SetPanelEvent( "onactivate", RemoveAbility( abPanel ) );
		sellCostLabel = $.CreatePanel( "Label", abButton, sellCostLabelId );
        ResetSellAbilityList(abilityName,sellCostLabel,abPanel,playerId);
	}
	else    //更新图片跟技能名字
	{
		ResetSellAbilityList(abilityName,sellCostLabel,abPanel,playerId);
        abPanel.abilityname = abilityName;
        abPanel.data.name=abPanel.abilityname;
	}
}


function ResetSellAbilityList(abilityName,sellCostLabel,abPanel,playerId)
{
	    abPanel.abilityname = abilityName;
        abPanel.data.abilityName=abPanel.abilityname;
	    var playerHeroIndex=Players.GetPlayerHeroEntityIndex(playerId) ;
	    var abilityIndex=Entities.GetAbilityByName(playerHeroIndex, abilityName );
    	var abilityCost=GetAbilityCost(abilityName);
    	var abilityLevel=Abilities.GetLevel(abilityIndex);

        if (noReturnAbility[abilityName] == true)
        {
        	 abilityLevel=1
        }         
    	var pointsReturn=abilityCost+abilityLevel-1;
    	var sellCost=Players.GetLevel(playerId)*pointsReturn*30;
        sellCostLabel.text="-"+sellCost;
    	abPanel.data.abilityCost=abilityCost;
    	var str= abilityName.substring(0, 4);  //专属技能与不能卖的技能
		if (str=="self" || unsellableAbility[abilityName]==true)
		{
           abPanel.GetParent().enabled=false;
           sellCostLabel.SetHasClass( "hidden", true );
		}
		else
		{
           abPanel.GetParent().enabled=true;
           sellCostLabel.SetHasClass( "hidden", false );
		}
        if (Players.GetGold(playerId)<sellCost)
        {
            abPanel.SetHasClass( "notEnoughDark", true );
        }
        else
        {
            abPanel.SetHasClass( "notEnoughDark", false );
        }
}


function ChangeToBuyPanel(isButtonEvent)
{
    var buyPanel= $("#buyPanel")
    buyPanel.SetHasClass( "hidden", false);
    var sellPanel= $("#sellPanel")
    sellPanel.SetHasClass( "hidden", true );
    if (isButtonEvent) 
    {
    Game.EmitSound("ui.switchview");
    }
}

function ChangeToSellPanel()
{
    var buyPanel= $("#buyPanel")
    buyPanel.SetHasClass( "hidden", true);
    var sellPanel= $("#sellPanel")
    sellPanel.SetHasClass( "hidden", false );
    var  playerId = Game.GetLocalPlayerInfo().player_id;
    PlayerAbilityListUpdate(playerId);
    Game.EmitSound("ui.switchview");
}

function SetAllAbilityUnabled(abPanel)
{
	for (var i = 1 ;i <= 6; i++) 
	{
		var abButtonId = "_ability_new_"+ i;
		var abButton=abPanel.GetParent().GetParent().FindChild(abButtonId);
		if (abButton)
		{
			abButton.enabled=false;
		}
	}
}




var PreviewHero = ( function( heroInfo )
{
	return function()
	{
        var playerId = Game.GetLocalPlayerInfo().player_id; 
		Update_Heroes_Table();
		Hero_Ability_List_Update( heroInfo.heroName,playerId,true);
		CurrentHero[playerId]=heroInfo.heroName;
	}
});

var AddAbility = ( function(abPanel )
{
	return function()
	{
		if (abPanel.data.reachFive && abPanel.data.enough)
		{
           SetAllAbilityUnabled(abPanel);
		}
		if (abPanel.data.enough)
		{
			abPanel.GetParent().enabled=false;
		}
		GameEvents.SendCustomGameEventToServer( "AddAbility", abPanel.data );
	}
});

var RemoveAbility = ( function(abPanel)
{
	return function()
	{  
		GameEvents.SendCustomGameEventToServer( "RemoveAbility", abPanel.data );
	}
});






function UpdateAbilityList(keys)
{
	var isButtonEvent=true;
	if (keys.heroName==false)
	{
        keys.heroName=CurrentHero[keys.playerId];  
        isButtonEvent=false;
	}
	Hero_Ability_List_Update(keys.heroName,keys.playerId,isButtonEvent);    //技能更新完毕，Lua通知UI更新英雄技能列表
}


function UpdatePlayerAbilityList(keys)
{
	PlayerAbilityListUpdate(keys.playerId);    //技能更新完毕，Lua通知UI更新英雄技能列表
}



function HideMainBlock()
{
	var mainBlock = $("#mainShop");
    mainBlock.invisible=true;
    mainBlock.SetHasClass("Hidden", true);
}



(function()
{
	Update_Heroes_Table();
	HideMainBlock();
	GameEvents.Subscribe( "UpdateAbilityList", UpdateAbilityList );
	GameEvents.Subscribe( "UpdatePlayerAbilityList", UpdatePlayerAbilityList );
})();

