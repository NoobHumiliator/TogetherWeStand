"use strict";

function OnGameEnd(data){

	$("#EndScreen").SetHasClass( "Hidden", false )
	$("#time_cost_var").text=data.timecost.toFixed(2)+"s"

    if (data.acheivement_flag==1)
    {
    	$("#succeed_or_not").text=$.Localize("#succeed")
    	$("#succeed_or_not").SetHasClass( "Fail", false )
    	$("#succeed_or_not").SetHasClass( "Succeed", true )
    }
    else
    {
    	$("#succeed_or_not").text=$.Localize("#fail")
    	$("#succeed_or_not").SetHasClass( "Succeed", false )
    	$("#succeed_or_not").SetHasClass( "Fail", true )
    }


	for (var i = 1; i <= data.playercount; i=i+1) {
		var linedata = data[""+i] 

		//$.Msg( data.playercount )
		var line = $.CreatePanel( "Panel", $("#BoardLines"), "player"+linedata.playerid)
		line.BLoadLayout( "file://{resources}/layout/custom_game/tws_round_end_line.xml", false,false)
		line.SetHasClass( "RankLine"+i, true )

		var playerdata = Game.GetPlayerInfo(linedata.playerid)
        

		var ranklabel = GetByClass(line,"RankLabel")
		ranklabel.text = i
		ranklabel.SetHasClass( "Rank"+i, true )

		var avatarPanel = line.FindChildTraverse("new_avatar")
		//$.Msg(avatarPanel.steamid)
		avatarPanel.steamid = playerdata.player_steamid
        //$.Msg(playerdata.player_steamid)
       
		var SteamNameLabel = GetByClass(line, "SteamNameLabel")
		SteamNameLabel.steamid = playerdata.player_steamid
        
        var EndSpeedRank = GetByClass(line, "EndSpeedRank")
		EndSpeedRank.text = (linedata.total_damage/1000).toFixed(1)+"k"

        var EndExplorRank = GetByClass(line, "EndExplorRank")
		EndExplorRank.text = linedata.total_heal

	};
    var maxtime = 8
	var tik =  1
	var time = maxtime
	var now = Game.GetDOTATime( false, true )
	var timetik = function(){
		time = maxtime + now - Game.GetDOTATime( false, true )
		if(time>0){	
			$.Schedule( tik, timetik)
		}else{
			CountDownFinish(data.playercount)
		}
	}
	$.Schedule( tik, timetik)

}

function CountDownFinish(playercount){

	$("#EndScreen").SetHasClass( "Hidden",true)
	for (var i = 1; i <= playercount; i=i+1) 
	{
	 var line = GetByClass($("#BoardLines"), "RankLine"+i)
     line.DeleteAsync(0)
    }

}



function GetByClass(parent, classs){
	var children = parent.FindChildrenWithClassTraverse(classs)
	return children[0]
}

function FormatTime(time, fixed){
	var min = Math.floor( time /60)
	var sec = new Number(time %60)
	var timertext = ""
	timertext+=min
	timertext+=":"
	if (sec <10)
		timertext+="0"
	timertext+=sec.toFixed(fixed)
	return timertext
}

(function(){ 
	GameEvents.Subscribe( "game_end", OnGameEnd )
})();