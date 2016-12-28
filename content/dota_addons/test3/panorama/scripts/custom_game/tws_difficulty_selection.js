"use strict";

var initTime=null;
var levelInitTime=null;
var setupTime=null;
var levelChoose=1;


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
        $("#TrialAvatar").RemoveAndDeleteChildren();
		$("#TrialAvatar2").RemoveAndDeleteChildren();

        var easyNumber=0;
        var normalNumber=0;
        var hardNumber=0;
        var trialNumber=0;
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
		for (var i = 1; i <= playerNumber; i++) 
		{
			if (data.selectionData["trial"][i])
			{
				if (trialNumber<3)
				{
					var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
					var heroName=Entities.GetUnitName( heroIndex );
					var notification = $.CreatePanel('DOTAHeroImage', $("#TrialAvatar"), '');
					notification.heroimagestyle = "icon";
					notification.heroname = heroName;
					notification.hittest = false;
					trialNumber=trialNumber+1;
				}
				else
				{
					var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
					var heroName=Entities.GetUnitName( heroIndex );
					var notification = $.CreatePanel('DOTAHeroImage', $("#TrialAvatar2"),'');
					notification.heroimagestyle = "icon";
					notification.heroname = heroName;
					notification.hittest = false;
					trialNumber=trialNumber+1;
				}
			}
		}   
		$("#DifficultyEasyValue").text= easyNumber;
		$("#DifficultyNormalValue").text= normalNumber;
		$("#DifficultyHardValue").text= hardNumber;
		$("#DifficultyTrialValue").text= trialNumber;
	}
}

function ConfirmDifficulty() {
	$("#DifficultySelectionPanel").SetHasClass( "Opacity", true ); 
}

function ConfirmTrialLevel() {
	$("#TrailLevelPanel").SetHasClass( "Opacity", true ); 
}



var DifficultyTitles = [$.Localize("#easy"), $.Localize("#normal"), $.Localize("#hard"),$.Localize("#trial")];

var LevelText=$.Localize("#trial_level");

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
	    if (data.difficulty=="trial")
		{
			announceText.text=DifficultyTitles[3]+" "+data.level;
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

function ShowTrialLevelPanel(data)
{
    var trailLevelPanel=$("#TrailLevelPanel");
    if (trailLevelPanel)
    {
		trailLevelPanel.SetHasClass("Opacity", false);
        setupTime=data.setupTime;
		UpdateTrialLevelTimer();
		var trailLevelContainer=trailLevelPanel.FindChildInLayoutFile("TrialLevelContainer");
		for (var i=1; i<=50;i++){
			 var level_line = $.CreatePanel("RadioButton", trailLevelContainer, "LevelLine_"+i);
		     level_line.BLoadLayout("file://{resources}/layout/custom_game/tws_trial_level_line.xml", false, false);
		     level_line.SetPanelEvent( "onselect",  ChangeLevelChoose(i));
		     level_line.FindChildInLayoutFile("TrialLevelLineText").text=LevelText+i;
		}
    }
}

var ChangeLevelChoose =( function ChangeLevelChoose(i)
{
    return function()
	{
	    levelChoose=i;
	}
});

var SendTrialLeveltoServer = ( function(data)
{
	return function()
	{   
        var playerId = Game.GetLocalPlayerInfo().player_id;     
        var data={
            playerId: playerId,
		    levelChoose: levelChoose,
         }
		GameEvents.SendCustomGameEventToServer( "SendTrialLeveltoServer", data );
	}
});


function UpdateTrialLevelTimer()
{
	var gameTime = Game.GetGameTime();
	if (levelInitTime==null)
	{
		levelInitTime=gameTime
	}
	var time = setupTime-Math.max(0, Math.floor( gameTime-levelInitTime));
	var timeStr = time.toString();
	if ($("#RemainingTrialLevelTime"))
	{
		if( $("#RemainingTrialLevelTime").text != timeStr )
		{
			$("#RemainingTrialLevelTime").text = timeStr;
		}
		if( time==0 )
		{
			$("#TrailLevelPanel").SetHasClass( "Opacity", true );
			var playerId = Game.GetLocalPlayerInfo().player_id;     
		    var data={
		        playerId: playerId,
			    levelChoose: levelChoose,
		     }
			GameEvents.SendCustomGameEventToServer( "SendTrialLeveltoServer", data );
			return;
		}
	}
	$.Schedule( 0.2, UpdateTrialLevelTimer );
}









(function()
{
	Game.AutoAssignPlayersToTeams();
	UpdateTimer();
	GameEvents.Subscribe("SelectDifficultyReturn",SelectDifficultyReturn);
    GameEvents.Subscribe("AnnounceDifficulty",AnnounceDifficulty);
    GameEvents.Subscribe("ShowTrialLevelPanel",ShowTrialLevelPanel);
})();
