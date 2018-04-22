"use strict";


var layoutMap ={
    "1" : "file://{resources}/layout/custom_game/tws_rank_line_one_player.xml",
    "2" : "file://{resources}/layout/custom_game/tws_rank_line_two_player.xml",
    "3" : "file://{resources}/layout/custom_game/tws_rank_line_three_player.xml",
    "4" : "file://{resources}/layout/custom_game/tws_rank_line_four_player.xml",
    "5" : "file://{resources}/layout/custom_game/tws_rank_line_five_player.xml",
    "6" : "file://{resources}/layout/custom_game/tws_rank_line_one_player.xml",
    "7" : "file://{resources}/layout/custom_game/tws_rank_line_two_player.xml",
    "8" : "file://{resources}/layout/custom_game/tws_rank_line_three_player.xml",
    "9" : "file://{resources}/layout/custom_game/tws_rank_line_four_player.xml",
    "10" : "file://{resources}/layout/custom_game/tws_rank_line_five_player.xml",
};

var RankPanels=["OnePlayerPanel","TwoPlayerPanel","ThreePlayerPanel","FourPlayerPanel","FivePlayerPanel",
"TrailOnePlayerPanel","TrailTwoPlayerPanel","TrailThreePlayerPanel","TrailFourPlayerPanel","TrailFivePlayerPanel"];

var currnet_page=null;
var currnet_player_number=null;
var current_rank="Hard";  //Hard or Trail

function ShowPage(data)
{
    ShowRankPanel(data.player_number,data.page_number,data.table);  //数据到达，更新下一页数据

    if (data.page_number==1)   //遍历第一页数据，记录本地玩家是第几名
    {
        var CustomUIContainer_Hud= $('#Title').GetParent().GetParent().GetParent().GetParent().GetParent().GetParent().FindChild('CustomUIContainer_Hud');
        var particlePanelHub=CustomUIContainer_Hud.FindChild('ParticlePanelHub');

        var rank
        var playerSteamId = Game.GetLocalPlayerInfo().player_steamid;     //玩家Steam ID
        playerSteamId=convertToSteamId32(playerSteamId)

        //$.Msg("playerId"+playerSteamId)

        for (var i=1; i<=30;i++){
          if (typeof(data.table)!="undefined"&&data.table.hasOwnProperty(i))
          {
             var data_line=data.table[i];
             var player_ids = data_line["player_steam_ids"].split(';');
              if (rank!=null)
             {
                break;
             }
              for (var j in player_ids)
             {
                  //$.Msg("j"+player_ids[j])
                 if ( playerSteamId.toString() ==player_ids[j].toString() )
                 {                 
                   rank=i;  
                 }
                 if (rank!=null)
                 {
                    break;
                 }
             }
          }
        }
        if (rank!=null&&( !particlePanelHub.hasOwnProperty("rank") || particlePanelHub.rank==null || particlePanelHub.rank>rank))
        {
           particlePanelHub.rank=rank  //记录玩家最好成绩
           //$.Msg("new Rank"+particlePanelHub.rank)
        }
    }
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

 //从试炼排行切换回困难排行
function ShowHardRank()
{
  current_rank="Hard";
  SwitchPanel(currnet_player_number);
}

//从困难排行切换回试炼排行
function ShowTrailRank()
{
  current_rank="Trail";
  SwitchPanel(currnet_player_number);
}



function SwitchPanel(player_number)
{

    if  (current_rank=="Trail" && player_number<6)
    {
      player_number=player_number+5
    }
    
    if  (current_rank=="Hard" && player_number>5)
    {
      player_number=player_number-5
    }
    
    GameEvents.SendCustomGameEventToServer( "RequestRankData", {page_number:1,player_number:player_number});
    
    if (player_number==1)
    {
      $('#OnePlayerPanel').SetHasClass("Hidden", false);
      $('#TwoPlayerPanel').SetHasClass("Hidden", true);
      $('#ThreePlayerPanel').SetHasClass("Hidden", true);
      $('#FourPlayerPanel').SetHasClass("Hidden", true);
      $('#FivePlayerPanel').SetHasClass("Hidden", true);
      HideTrailPanel();
    }

    if (player_number==2)
    {
      $('#OnePlayerPanel').SetHasClass("Hidden", true);
      $('#TwoPlayerPanel').SetHasClass("Hidden", false);
      $('#ThreePlayerPanel').SetHasClass("Hidden", true);
      $('#FourPlayerPanel').SetHasClass("Hidden", true);
      $('#FivePlayerPanel').SetHasClass("Hidden", true);
      HideTrailPanel();
    }

    if (player_number==3)
    {
      $('#OnePlayerPanel').SetHasClass("Hidden", true);
      $('#TwoPlayerPanel').SetHasClass("Hidden", true);
      $('#ThreePlayerPanel').SetHasClass("Hidden", false);
      $('#FourPlayerPanel').SetHasClass("Hidden", true);
      $('#FivePlayerPanel').SetHasClass("Hidden", true);
      HideTrailPanel();
    }

    if (player_number==4)
    {
      $('#OnePlayerPanel').SetHasClass("Hidden", true);
      $('#TwoPlayerPanel').SetHasClass("Hidden", true);
      $('#ThreePlayerPanel').SetHasClass("Hidden", true);
      $('#FourPlayerPanel').SetHasClass("Hidden", false);
      $('#FivePlayerPanel').SetHasClass("Hidden", true);
      HideTrailPanel();
    }

    if (player_number==5)
    {
      $('#OnePlayerPanel').SetHasClass("Hidden", true);
      $('#TwoPlayerPanel').SetHasClass("Hidden", true);
      $('#ThreePlayerPanel').SetHasClass("Hidden", true);
      $('#FourPlayerPanel').SetHasClass("Hidden", true);
      $('#FivePlayerPanel').SetHasClass("Hidden", false);
      HideTrailPanel();
    }

    if (player_number==6)
    {
        $('#TrailOnePlayerPanel').SetHasClass("Hidden", false);
        $('#TrailTwoPlayerPanel').SetHasClass("Hidden", true);
        $('#TrailThreePlayerPanel').SetHasClass("Hidden", true);
        $('#TrailFourPlayerPanel').SetHasClass("Hidden", true);
        $('#TrailFivePlayerPanel').SetHasClass("Hidden", true);
        HideHardPanel();
    }

    if (player_number==7)
    {
        $('#TrailOnePlayerPanel').SetHasClass("Hidden", true);
        $('#TrailTwoPlayerPanel').SetHasClass("Hidden", false);
        $('#TrailThreePlayerPanel').SetHasClass("Hidden", true);
        $('#TrailFourPlayerPanel').SetHasClass("Hidden", true);
        $('#TrailFivePlayerPanel').SetHasClass("Hidden", true);
        HideHardPanel();
    }

    if (player_number==8)
    {
        $('#TrailOnePlayerPanel').SetHasClass("Hidden", true);
        $('#TrailTwoPlayerPanel').SetHasClass("Hidden", true);
        $('#TrailThreePlayerPanel').SetHasClass("Hidden", false);
        $('#TrailFourPlayerPanel').SetHasClass("Hidden", true);
        $('#TrailFivePlayerPanel').SetHasClass("Hidden", true);
        HideHardPanel();
    }

    if (player_number==9)
    {
        $('#TrailOnePlayerPanel').SetHasClass("Hidden", true);
        $('#TrailTwoPlayerPanel').SetHasClass("Hidden", true);
        $('#TrailThreePlayerPanel').SetHasClass("Hidden", true);
        $('#TrailFourPlayerPanel').SetHasClass("Hidden", false);
        $('#TrailFivePlayerPanel').SetHasClass("Hidden", true);
        HideHardPanel();
    }
   
    if (player_number==10)
    {
        $('#TrailOnePlayerPanel').SetHasClass("Hidden", true);
        $('#TrailTwoPlayerPanel').SetHasClass("Hidden", true);
        $('#TrailThreePlayerPanel').SetHasClass("Hidden", true);
        $('#TrailFourPlayerPanel').SetHasClass("Hidden", true);
        $('#TrailFivePlayerPanel').SetHasClass("Hidden", false);
        HideHardPanel();
    }
}



function HideTrailPanel()
{
    $('#TrailOnePlayerPanel').SetHasClass("Hidden", true);
    $('#TrailTwoPlayerPanel').SetHasClass("Hidden", true);
    $('#TrailThreePlayerPanel').SetHasClass("Hidden", true);
    $('#TrailFourPlayerPanel').SetHasClass("Hidden", true);
    $('#TrailFivePlayerPanel').SetHasClass("Hidden", true);
}


function HideHardPanel()
{
    $('#OnePlayerPanel').SetHasClass("Hidden", true);
    $('#TwoPlayerPanel').SetHasClass("Hidden", true);
    $('#ThreePlayerPanel').SetHasClass("Hidden", true);
    $('#FourPlayerPanel').SetHasClass("Hidden", true);
    $('#FivePlayerPanel').SetHasClass("Hidden", true);
}





function ShowRankPanel(player_number,page_number,page_table)
{

  var rank_panel = $("#"+RankPanels[player_number-1]);
  var last_page=false;
  for (var i=1; i<=30;i++){
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
         $.Msg(player_ids)
         $.Msg(player_number)
         for (var j in player_ids)
         {
          team_line.FindChildInLayoutFile( "PlayerAvatarImage"+index ).steamid=ConvertToSteamid64(player_ids[j]);
          if (parseInt(player_number%5)==1&&index==1)  //为单人玩家显示姓名
          {
             team_line.FindChildInLayoutFile("PlayerUserName").steamid = ConvertToSteamid64(player_ids[j]); 
          }
          if (parseInt(player_number%5)==2)  //为双人玩家显示姓名
          {
             team_line.FindChildInLayoutFile("PlayerUserName"+index).steamid = ConvertToSteamid64(player_ids[j]); 
          }
          if (parseInt(player_number%5)==3)  //为三人玩家显示姓名
          {
             team_line.FindChildInLayoutFile("PlayerUserName"+index).steamid = ConvertToSteamid64(player_ids[j]); 
          }
          index++;
         }
         team_line.FindChildInLayoutFile("TeamIndex").text=i+30*(page_number-1)+"";
         team_line.FindChildInLayoutFile("MaxRound").text=data_line["max_round"];
         if (player_number<=5)
         {
            team_line.FindChildInLayoutFile("TimeCost").text=FormatSeconds(data_line["time_cost"]);
            $("#InformerLabelTimeCost").text=$.Localize("#timeCost");
         }
         else
         {  
            $("#InformerLabelTimeCost").text=$.Localize("#trail_level");
            team_line.FindChildInLayoutFile("TimeCost").text=parseInt(data_line["map_difficulty"])-3;
         }
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

function ConvertToSteamid64(steamid32)  //32位转64位
{
	var steamid64 = '765' + (parseInt(steamid32) + 61197960265728).toString();
	return steamid64;
}

function convertToSteamId32(steamid64) {   //64位转32位
    return steamid64.substr(3) - 61197960265728;
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
   $("#SecondaryTabButton_5").checked=true;
   $("#HardRankPrimaryTabButton").checked=true;
})();