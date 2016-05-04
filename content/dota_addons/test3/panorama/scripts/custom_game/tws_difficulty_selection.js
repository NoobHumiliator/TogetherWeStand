"use strict";

var initTime=null


function UpdateTimer()
{
	var gameTime = Game.GetGameTime();
	if (initTime==null)
	{
		initTime=gameTime
	}
	//$.Msg("game time"+gameTime)
	var time = (15-Math.max( 0, Math.floor( gameTime-initTime) ) ).toString();
	if ($("#RemainingSetupTime"))
	{
		if( $("#RemainingSetupTime").text != time )
		{
			$("#RemainingSetupTime").text = time;
		}
		if( Game.GameStateIs(  DOTA_GameState.DOTA_GAMERULES_STATE_GAME_IN_PROGRESS ) )
		{
			$("#DifficultySelectionPanel").SetHasClass( "Opacity", true ); 
			return;
		}
	}
	$.Schedule( 0.2, UpdateTimer );
}


function SendCustomSelectDifficulty( difficulty ) {
	var pID = Game.GetLocalPlayerInfo().player_id; 
	GameEvents.SendCustomGameEventToServer("SelectDifficulty",{difficulty:difficulty ,playerID:pID});
}

//var number_test=0 

function SelectDifficultyReturn( data ) {

	if ($("#DifficultyEasyValue")) 
	{
		var playerNumber=Players.GetMaxPlayers();
        $.Msg(playerNumber);
		$("#EasyAvatar").RemoveAndDeleteChildren();
		$("#EasyAvatar2").RemoveAndDeleteChildren();
		$("#NormalAvatar").RemoveAndDeleteChildren();
		$("#NormalAvatar2").RemoveAndDeleteChildren();
		$("#HardAvatar").RemoveAndDeleteChildren();
		$("#HardAvatar2").RemoveAndDeleteChildren();
        
        var easyNumber=0;
        var normalNumber=0;
        var hardNumber=0;
		for (var i = 1; i <= playerNumber; i++) 
		{
			if (data.selectionData["easy"][i])
			{
				if (easyNumber<3)
				{
					var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
					var heroName=Entities.GetUnitName( heroIndex );
					var notification = $.CreatePanel('DOTAHeroImage', $("#EasyAvatar"), '');
					notification.heroimagestyle = "icon";
					notification.heroname = heroName;
					notification.hittest = false;
					easyNumber=easyNumber+1;
				}
				else
				{
					var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
					var heroName=Entities.GetUnitName( heroIndex );
					var notification = $.CreatePanel('DOTAHeroImage', $("#EasyAvatar2"),'');
					notification.heroimagestyle = "icon";
					notification.heroname = heroName;
					notification.hittest = false;
					easyNumber=easyNumber+1;
				}
			}
		}
		for (var i = 1; i <= playerNumber; i++) 
		{
			if (data.selectionData["normal"][i])
			{ 
				if (normalNumber<3)
				{
					var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
					var heroName=Entities.GetUnitName( heroIndex );
					var notification = $.CreatePanel('DOTAHeroImage', $("#NormalAvatar"), '');
					notification.heroimagestyle = "icon";
					notification.heroname = heroName;
					notification.hittest = false;
					normalNumber=normalNumber+1;
				}
				else
				{
					var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
					var heroName=Entities.GetUnitName( heroIndex );
					var notification = $.CreatePanel('DOTAHeroImage', $("#NormalAvatar2"),'');
					notification.heroimagestyle = "icon";
					notification.heroname = heroName;
					notification.hittest = false;
					normalNumber=normalNumber+1;
				}
			}
		}
		for (var i = 1; i <= playerNumber; i++) 
		{
			if (data.selectionData["hard"][i])
			{
				if (hardNumber<3)
				{
					var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
					var heroName=Entities.GetUnitName( heroIndex );
					var notification = $.CreatePanel('DOTAHeroImage', $("#HardAvatar"), '');
					notification.heroimagestyle = "icon";
					notification.heroname = heroName;
					notification.hittest = false;
					hardNumber=hardNumber+1;
				}
				else
				{
					var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
					var heroName=Entities.GetUnitName( heroIndex );
					var notification = $.CreatePanel('DOTAHeroImage', $("#HardAvatar2"),'');
					notification.heroimagestyle = "icon";
					notification.heroname = heroName;
					notification.hittest = false;
					hardNumber=hardNumber+1;
				}
			}
		}   
		$("#DifficultyEasyValue").text= easyNumber;
		$("#DifficultyNormalValue").text= normalNumber;
		$("#DifficultyHardValue").text= hardNumber;
	}
}

function ConfirmDifficulty() {
	$("#DifficultySelectionPanel").SetHasClass( "Opacity", true ); 
}

var DifficultyTitles = [$.Localize("#easy"), $.Localize("#normal"), $.Localize("#hard")];


function AnnounceDifficulty( data ) 
{
	var announceText=$("#DifficultyAnnounceText");
	if (announceText)
	{
		announceText.SetHasClass("hidden", false);
		if (data.difficulty=="easy")
		{
			announceText.text=DifficultyTitles[0];
		}
		if (data.difficulty=="normal")
		{
			announceText.text=DifficultyTitles[1];
		}
		if (data.difficulty=="hard")
		{
			announceText.text=DifficultyTitles[2];
		}
	}
	$.Schedule(3.0,HideAnnouncemnet);
}

function HideAnnouncemnet() 
{
	var difficultyAnnounceText=$("#DifficultyAnnounceText");
	if (difficultyAnnounceText)
	{
	   difficultyAnnounceText.SetHasClass("Opacity", true);
    }
}


(function()
{
	Game.AutoAssignPlayersToTeams();
	UpdateTimer();
	GameEvents.Subscribe("SelectDifficultyReturn",SelectDifficultyReturn);
    GameEvents.Subscribe("AnnounceDifficulty",AnnounceDifficulty);
})();
