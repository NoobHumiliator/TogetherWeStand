"use strict";


var layoutMap ={
    "1" : "file://{resources}/layout/custom_game/tws_rank_line_one_player.xml",
    "2" : "file://{resources}/layout/custom_game/tws_rank_line_two_player.xml",
    "3" : "file://{resources}/layout/custom_game/tws_rank_line_three_player.xml",
    "4" : "file://{resources}/layout/custom_game/tws_rank_line_four_player.xml",
    "5" : "file://{resources}/layout/custom_game/tws_rank_line_five_player.xml",
};

var RankPanels=["OnePlayerPanel","TwoPlayerPanel","ThreePlayerPanel","FourPlayerPanel","FivePlayerPanel"];

var currnet_page=null;
var currnet_player_number=null;


function ShowPage(data)
{
    ShowRankPanel(data.player_number,data.page_number,data.table);  //数据到达，更新下一页数据
    //$.Msg("player_number: "+  data.player_number+ "page_number:"+data.page_number);
    //$.Msg(data.table);
}

function ShowNextPage()
{
    GameEvents.SendCustomGameEventToServer( "RequestRankData", {page_number:currnet_page+1,player_number:currnet_player_number});
}
function ShowPrePage()
{
    GameEvents.SendCustomGameEventToServer( "RequestRankData", {page_number:currnet_page-1,player_number:currnet_player_number});
}

function ShowOnePlayer()
{
    GameEvents.SendCustomGameEventToServer( "RequestRankData", {page_number:1,player_number:1});
    $('#OnePlayerPanel').SetHasClass("Hidden", false);
    $('#TwoPlayerPanel').SetHasClass("Hidden", true);
    $('#ThreePlayerPanel').SetHasClass("Hidden", true);
    $('#FourPlayerPanel').SetHasClass("Hidden", true);
    $('#FivePlayerPanel').SetHasClass("Hidden", true);
}
function ShowTwoPlayer()
{
    GameEvents.SendCustomGameEventToServer( "RequestRankData", {page_number:1,player_number:2});
    $('#OnePlayerPanel').SetHasClass("Hidden", true);
    $('#TwoPlayerPanel').SetHasClass("Hidden", false);
    $('#ThreePlayerPanel').SetHasClass("Hidden", true);
    $('#FourPlayerPanel').SetHasClass("Hidden", true);
    $('#FivePlayerPanel').SetHasClass("Hidden", true);
}
function ShowThreePlayer()
{
    GameEvents.SendCustomGameEventToServer( "RequestRankData", {page_number:1,player_number:3});
    $('#OnePlayerPanel').SetHasClass("Hidden", true);
    $('#TwoPlayerPanel').SetHasClass("Hidden", true);
    $('#ThreePlayerPanel').SetHasClass("Hidden", false);
    $('#FourPlayerPanel').SetHasClass("Hidden", true);
    $('#FivePlayerPanel').SetHasClass("Hidden", true);
}
function ShowFourPlayer()
{
    GameEvents.SendCustomGameEventToServer( "RequestRankData", {page_number:1,player_number:4});
    $('#OnePlayerPanel').SetHasClass("Hidden", true);
    $('#TwoPlayerPanel').SetHasClass("Hidden", true);
    $('#ThreePlayerPanel').SetHasClass("Hidden", true);
    $('#FourPlayerPanel').SetHasClass("Hidden", false);
    $('#FivePlayerPanel').SetHasClass("Hidden", true);
}
function ShowFivePlayer()
{
    GameEvents.SendCustomGameEventToServer( "RequestRankData", {page_number:1,player_number:5});
    $('#OnePlayerPanel').SetHasClass("Hidden", true);
    $('#TwoPlayerPanel').SetHasClass("Hidden", true);
    $('#ThreePlayerPanel').SetHasClass("Hidden", true);
    $('#FourPlayerPanel').SetHasClass("Hidden", true);
    $('#FivePlayerPanel').SetHasClass("Hidden", false);
}



function ShowRankPanel(player_number,page_number,page_table)
{
  var rank_panel = $("#"+RankPanels[player_number-1]);
  var last_page=false;
  for (var i=1; i<=150;i++){
      var team_line = rank_panel.FindChild("TeamLine_"+i);
      if (!team_line)
      {
        var team_line = $.CreatePanel("Panel", rank_panel, "TeamLine_"+i);
        team_line.BLoadLayout(layoutMap[player_number], false, false)
      }
      if (typeof(page_table)=="undefined"||!page_table.hasOwnProperty(i))
      {
        team_line.SetHasClass("Hidden", true);
        last_page=true;
      }
      else
      {
         var data_line=page_table[i];
         team_line.SetHasClass("Hidden", false);
         var player_ids = data_line["player_steam_ids"].split(';');
         var index=1;

         for (var j in player_ids)
         {
          team_line.FindChildInLayoutFile( "PlayerAvatarImage"+index ).steamid=ConvertToSteamid64(player_ids[j]);
          if (parseInt(player_number)==1&&index==1)  //为单人玩家显示姓名
          {
             team_line.FindChildInLayoutFile("PlayerUserName").steamid = ConvertToSteamid64(player_ids[j]); 
          }
          if (parseInt(player_number)==2)  //为双人玩家显示姓名
          {
             team_line.FindChildInLayoutFile("PlayerUserName"+index).steamid = ConvertToSteamid64(player_ids[j]); 
          }
          if (parseInt(player_number)==3)  //为三人玩家显示姓名
          {
             team_line.FindChildInLayoutFile("PlayerUserName"+index).steamid = ConvertToSteamid64(player_ids[j]); 
          }
          index++;
         }
         team_line.FindChildInLayoutFile("TeamIndex").text=i+150*(page_number-1)+"";
         team_line.FindChildInLayoutFile("MaxRound").text=data_line["max_round"];
         team_line.FindChildInLayoutFile("TimeCost").text=FormatSeconds(data_line["time_cost"]);
      }
  }
   currnet_page=page_number;
   currnet_player_number=player_number;
  if (page_number==1) //第一页向前翻页禁止，其他页不禁止
  {
    $("#NavigetePreButton").enabled=false;
  }
  else
  {
    $("#NavigetePreButton").enabled=true;
  }
  if(last_page)
  {
     $("#NavigeteNextButton").enabled=false;
  }
  else
  {
     $("#NavigeteNextButton").enabled=true;
  }
}

function ConvertToSteamid64(steamid32)
{
	var steamid64 = '765' + (parseInt(steamid32) + 61197960265728).toString();
	return steamid64;
}


function FormatSeconds(value) {
    var theTime = parseInt(value);// 秒
    var theTime1 = 0;// 分
    var theTime2 = 0;// 小时
    if(theTime > 60) {
        theTime1 = parseInt(theTime/60);
        theTime = parseInt(theTime%60);
            if(theTime1 > 60) {
            theTime2 = parseInt(theTime1/60);
            theTime1 = parseInt(theTime1%60);
            }
    }
        var result = ""+parseInt(theTime)+"\"";
        if(theTime1 > 0) {
           result = ""+parseInt(theTime1)+"\'"+result;
        }
        if(theTime2 > 0) {
          result = ""+parseInt(theTime2)+":"+result;
        }
    return result;
}


(function()
{
   GameEvents.Subscribe( "show_page", ShowPage )
})();