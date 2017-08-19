"use strict";

var initTime=null;
var setupTime=null;
var levelChoose=1;
var branchToChooseNo=2; //全局变量 总共多少个分支可供选择

function UpdateTimer()
{
	var gameTime = Game.GetGameTime();
	if (initTime==null)
	{
		initTime=gameTime
	}
	var time = (15-Math.max( 0, Math.floor( gameTime-initTime) ) ).toString();
	if ($("#RemainingBranchSelectTime"))
	{
		if( $("#RemainingBranchSelectTime").text != time )
		{
			$("#RemainingBranchSelectTime").text = time;
		}
		if( 15-Math.max( 0, Math.floor( gameTime-initTime) )< 0  ) //分支选择计时到
		{
			$("#BranchSelectionPanel").SetHasClass( "Opacity", true ); 
			initTime=null;
			return;
		}
	}
	$.Schedule( 0.2, UpdateTimer );
}


function SendBranchSelection( branch ) {
	var pID = Game.GetLocalPlayerInfo().player_id; 
	GameEvents.SendCustomGameEventToServer("SelectBranch",{branch:branch ,playerID:pID});
}


function SelectBranchReturn( data ) {

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
       
        var branchNumber=[0,0,0,0,0,0,0]; //key是 分支编号 value 是分支选择人数
        var selectionData=data.selectionData; // Map  key为playerId value为所选分支

		for (var i = 1; i <= playerNumber; i++) 
		{
            var branch = selectionData[i]; //i玩家所选分支

            branchNumber[ branch ] = branchNumber[ branch ] +1 ; //选此分支的人数
            
            if (branchNumber[ branch ]<=3) //选此分支的人数少于等于3人
			{
				var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
				var heroName=Entities.GetUnitName( heroIndex );
				var notification = $.CreatePanel('DOTAHeroImage', $("#Branch_"+branchToChooseNo+"_"+branch+"_AvatarDown"), '');
				notification.heroimagestyle = "icon";
				notification.heroname = heroName;
				notification.hittest = false;
			}
			else
			{
				var heroIndex=Players.GetPlayerHeroEntityIndex(i-1);
				var heroName=Entities.GetUnitName( heroIndex );
				var notification = $.CreatePanel('DOTAHeroImage', $("#Branch_"+branchToChooseNo+"_"+branch+"_AvatarTop"), '');
				notification.heroimagestyle = "icon";
				notification.heroname = heroName;
				notification.hittest = false;
			}
		} 
        //设置玩家选择数量
        for (var i=0;i<=branchToChooseNo;i++)
        {
           $("#Branch_"+branchToChooseNo+"_"+i+"_AvatarDown").text= branchNumber[i];
        }

}

//确认分支选择
function ConfirmBranch() {
	$("#BranchSelectionPanel").SetHasClass( "Opacity", true ); 
}


var DifficultyTitles = [$.Localize("#easy"), $.Localize("#normal"), $.Localize("#hard"),$.Localize("#trial")];

var LevelText=$.Localize("#trial_level");



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



function ShowBranchSelection(keys)
{
     if (keys.branchNumber==2)  //双分支选择
	{
        $("#TwoBranchSelection").SetHasClass( "Opacity", false );  //显示双分支选择面板
	}
	if (keys.branchNumber==3)   //三分支选择
	{
        $("#ThreeBranchSelection").SetHasClass( "Opacity", false ); 
	}

	UpdateTimer(); //开始倒计时
}





(function()
{
	UpdateTimer();
	//展示分支选择窗口
	GameEvents.Subscribe("ShowBranchSelection",ShowBranchSelection);


	GameEvents.Subscribe("SelectDifficultyReturn",SelectDifficultyReturn);
})();
