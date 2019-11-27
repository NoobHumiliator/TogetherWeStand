"use strict";

var initTime = null;
var setupTime = null;
var levelChoose = 1;
var branchToChooseNo = 2; //全局变量 总共多少个分支可供选择

function UpdateTimer() {
	var gameTime = Game.GetGameTime();
	if (initTime == null) {
		initTime = gameTime
	}
	var time = (8 - Math.max(0, Math.floor(gameTime - initTime))).toString();
	if ($("#RemainingBranchSelectTime")) {
		if ($("#RemainingBranchSelectTime").text != time) {
			$("#RemainingBranchSelectTime").text = time;
		}
		if ((8 - Math.max(0, Math.floor(gameTime - initTime))) == 0) //分支选择计时到
		{
			$("#BranchSelectionPanel").SetHasClass("Opacity", true);
			initTime = null;
			return;
		}
	}
	$.Schedule(0.2, UpdateTimer);
}


function SendBranchSelection(branch) {
	var pID = Game.GetLocalPlayerInfo().player_id;
	GameEvents.SendCustomGameEventToServer("SelectBranch", { branch: branch, playerID: pID });
}


function SelectBranchReturn(data) {

	//先删掉全部的头像
	for (var i = 0; i <= branchToChooseNo; i++) {
		$("#Branch_" + branchToChooseNo + "_" + i + "_AvatarTop").RemoveAndDeleteChildren();
		$("#Branch_" + branchToChooseNo + "_" + i + "_AvatarDown").RemoveAndDeleteChildren();
	}
	//$.Msg(data.selectionData)
	var branchNumber = [0, 0, 0, 0, 0, 0, 0]; //key是 分支编号 value 是分支选择人数
	var selectionData = data.selectionData; // Map  key为playerId value为所选分支

	for (var i = 0; i < Object.keys(selectionData).length; i++) {
		var branch = selectionData[i]; //i玩家所选分支

		branchNumber[branch] = branchNumber[branch] + 1; //选此分支的人数

		if (branchNumber[branch] <= 3) //选此分支的人数少于等于3人
		{
			var heroIndex = Players.GetPlayerHeroEntityIndex(i);
			var heroName = Entities.GetUnitName(heroIndex);
			var notification = $.CreatePanel('DOTAHeroImage', $("#Branch_" + branchToChooseNo + "_" + branch + "_AvatarDown"), '');
			notification.heroimagestyle = "icon";
			notification.heroname = heroName;
			notification.hittest = false;
		}
		else {
			var heroIndex = Players.GetPlayerHeroEntityIndex(i);
			var heroName = Entities.GetUnitName(heroIndex);
			var notification = $.CreatePanel('DOTAHeroImage', $("#Branch_" + branchToChooseNo + "_" + branch + "_AvatarTop"), '');
			notification.heroimagestyle = "icon";
			notification.heroname = heroName;
			notification.hittest = false;
		}
	}
	//设置玩家选择数量
	for (var i = 0; i <= branchToChooseNo; i++) {
		$("#Branch_" + branchToChooseNo + "_" + i + "_Label").text = branchNumber[i];
	}

}

//确认分支选择
function ConfirmBranch() {
	$("#BranchSelectionPanel").SetHasClass("Opacity", true);
}

var ChangeLevelChoose = (function ChangeLevelChoose(i) {
	return function () {
		levelChoose = i;
	}
});

var SendTrialLeveltoServer = (function (data) {
	return function () {
		var playerId = Game.GetLocalPlayerInfo().player_id;
		var data = {
			playerId: playerId,
			levelChoose: levelChoose,
		}
		GameEvents.SendCustomGameEventToServer("SendTrialLeveltoServer", data);
	}
});

function ShowBranchSelection(keys) {
	var shortTitles = keys.shortTitles
	//$.Msg(shortTitles)
	branchToChooseNo = keys.branchNumber
	//显示主面板
	$("#BranchSelectionPanel").SetHasClass("Opacity", false);

	if (keys.branchNumber == 2)  //双分支选择
	{
		$("#TwoBranchSelection").SetHasClass("Opacity", false);  //显示双分支选择面板
		$("#Branch_2_1_Title").text = shortTitles[1];  //设置选择标题
		$("#Branch_2_2_Title").text = shortTitles[2];

	}
	if (keys.branchNumber == 3)   //三分支选择
	{
		$("#ThreeBranchSelection").SetHasClass("Opacity", false);
		$("#Branch_3_1_Title").text = shortTitles[1];
		$("#Branch_3_2_Title").text = shortTitles[2];
		$("#Branch_3_3_Title").text = shortTitles[3];
	}
	if (keys.branchNumber == 4)   //四分支选择
	{
		$("#ThreeBranchSelection").SetHasClass("Opacity", false);
		$("#Branch_3_1_Title").text = shortTitles[1];
		$("#Branch_3_2_Title").text = shortTitles[2];
		$("#Branch_3_3_Title").text = shortTitles[3];
		$("#Branch_3_4_Title").text = shortTitles[4];
	}

	UpdateTimer(); //开始倒计时
}

(function () {
	//展示分支选择窗口
	GameEvents.Subscribe("ShowBranchSelection", ShowBranchSelection);
	GameEvents.Subscribe("SelectBranchReturn", SelectBranchReturn);
})();