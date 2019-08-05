"use strict";


function SaveGame()  //向Lua传递确认信息
{
     var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
     var panelHub = $("#SavePanelHub")

     GameEvents.SendCustomGameEventToServer("SaveGame", { playerId: playerId, slotIndex: panelHub.slotIndex });

     var loadingPanel = $("#SaveLoading")
     loadingPanel.SetHasClass("hidden", false); //先用蒙版把整个UI遮住

}

function LoadGame() //读档
{
     var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
     var panelHub = $("#SavePanelHub")
     var slotIndex = panelHub.slotIndex
     var steam_id = Game.GetLocalPlayerInfo().player_steamid; //这里用64位置ID

     var radionButton = panelHub.FindChildTraverse("SaveRadioButton_" + slotIndex);

     GameEvents.SendCustomGameEventToServer("PrepareToLoadGame", { playerId: playerId, jsonData: radionButton.json_data, steamId: steam_id });

     var savePanelContainer = panelHub.FindChildTraverse("SavePanelContainer");
     savePanelContainer.SetHasClass("hidden", true)  //隐藏存档栏页面
}


function CancleGame()  //向Lua传递确认信息
{
     var container = $("#SavePanelContainer");
     container.SetHasClass("hidden", true);
}

function PopupLoadVote(keys)  //向Lua传递确认信息
{
     //$.Msg(keys.steamId)
     var panelHub = $("#SavePanelHub");
     var loadVotePanelContainer = panelHub.FindChildTraverse("LoadVotePanelContainer");
     loadVotePanelContainer.SetHasClass("hidden", false)  //展示出投票页面
     loadVotePanelContainer.FindChildTraverse("SponsorPlayerImage").steamid = keys.steamId
}



function Accpet() //同意读档
{
     var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
     var panelHub = $("#SavePanelHub")

     GameEvents.SendCustomGameEventToServer("AcceptToLoadGame", { playerId: playerId });

     var loadVotePanelContainer = panelHub.FindChildTraverse("LoadVotePanelContainer");
     loadVotePanelContainer.SetHasClass("hidden", true)  //隐藏投票页面
}

function Decline() //反对读档
{
     var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
     var panelHub = $("#SavePanelHub")

     var loadVotePanelContainer = panelHub.FindChildTraverse("LoadVotePanelContainer");
     loadVotePanelContainer.SetHasClass("hidden", true)  //隐藏投票页面
}


function ShowSaveTooltip(index) {
     var title = "#save_button_title";
     if (index == 1) {
          if ($("#SaveGameButton").enabled == false) {
               $.DispatchEvent("DOTAShowTitleTextTooltip", $("#SaveGameButton"), title, "");
          }
     }
     if (index == 2) {
          if ($("#LoadGameButton").enabled == false) {
               $.DispatchEvent("DOTAShowTitleTextTooltip", $("#LoadGameButton"), title, "");
          }
     }
}

function HideSaveTooltip(index) {
     if (index == 1) {
          if ($("#SaveGameButton").enabled == false) {
               $.DispatchEvent("DOTAHideTitleTextTooltip", $("#SaveGameButton"));
          }
     }
     if (index == 2) {
          if ($("#LoadGameButton").enabled == false) {
               $.DispatchEvent("DOTAHideTitleTextTooltip", $("#LoadGameButton"));
          }
     }
}

function SaveTestBackDoor(keys) {
     var loadGameButton = $("#LoadGameButton");
     var particlePanelHub = loadGameButton.GetParent().GetParent().GetParent().GetParent().FindChild("ParticlePanelHub");
     particlePanelHub.saveBackDoor = true;
}

(function () {
     GameEvents.Subscribe("PopupLoadVote", PopupLoadVote); //后台告知所有玩家弹出投票窗口
     GameEvents.Subscribe("SaveTestBackDoor", SaveTestBackDoor); //开后门测试存档
})();