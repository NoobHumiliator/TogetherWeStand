"use strict";

var particleNameMap = ["darkmoon", "sakura_trail", "rex", "frull", "black", "lava_trail", "paltinum_baby_roshan",
    "devourling_gold", "legion_wings", "legion_wings_vip"];

var RecordSelect = (function (particleName) {
    return function () {

        var button = $("#ParticleTriggerButton");
        var panelHub = button.GetParent().GetParent().GetParent().FindChild("ParticlePanelHub")
        panelHub.particleName = particleName; //记录下特效的名字
    }
});

var RecordSlotSelect = (function (index) {
    return function () {
        var button = $("#SaveTriggerButton");
        var panelHub = button.GetParent().GetParent().GetParent().FindChild("SavePanelHub")
        panelHub.slotIndex = index; //记录下选了第几个存档槽
    }
});

function ShowParticleBlock() {

    var button = $("#ParticleTriggerButton");
    var particlePanelHub = button.GetParent().GetParent().GetParent().FindChild("ParticlePanelHub");
    var container = particlePanelHub.FindChild("ParticlePanelContainer");
    $.DispatchEvent("DOTAHideTitleTextTooltip", $("#ParticleTriggerButton"));

    if (!container)  //如果不存在新建一个
    {
        particlePanelHub.BLoadLayoutSnippet("snippet_container");
        container = particlePanelHub.FindChild("ParticlePanelContainer");
        for (var i = 1; i <= 10; i++) {
            var radionButton = container.FindChildTraverse("ParticleRadioButton_" + i);
            var scenePanel = radionButton.BCreateChildren("<DOTAScenePanel style='width:290px;height:290px;' particleonly='false' id='scene_" + i + "' map='particle_model' camera='camera_" + i + "'/>");
            //var scenePanel=radionButton.BCreateChildren("<DOTAScenePanel style='width:300px;height:300px;' unit='faceless_rex' />");
            radionButton.SetPanelEvent("onactivate", RecordSelect(particleNameMap[i - 1]));
            radionButton.group = "particleRadios"

            if (i <= 5) //几个VIP的特效
            {
                radionButton.enabled = false
                var playerId = Players.GetLocalPlayer();
                var steam_id = Game.GetPlayerInfo(playerId).player_steamid;
                var vipLevel = CustomNetTables.GetTableValue("vipMap", "" + ConvertToSteamId32(steam_id)).level;
                if (vipLevel >= 1)  //vip等级大于1 可以选上面的一排
                {
                    radionButton.enabled = true
                }
            }

            if (i >= 6) //几个天梯等级的特效
            {
                radionButton.enabled = false
                if (particlePanelHub.hasOwnProperty("rank") && particlePanelHub.rank != null) {
                    if (particlePanelHub.rank <= 15 && i <= 6)  //前15
                    {
                        radionButton.enabled = true
                    }
                    if (particlePanelHub.rank <= 10 && i <= 7)  //前10
                    {
                        radionButton.enabled = true
                    }
                    if (particlePanelHub.rank <= 5 && i <= 8)  //前5
                    {
                        radionButton.enabled = true
                    }
                    if (particlePanelHub.rank <= 3 && i <= 9)  //前3
                    {
                        radionButton.enabled = true
                    }
                    if (particlePanelHub.rank <= 1 && i <= 10)  //前1
                    {
                        radionButton.enabled = true
                    }
                }
            }
        }
        $.Schedule(1.0, InitParticle);
    }
    else  //如果存在就删除
    {
        for (var i = 1; i <= 10; i++) {
            var radionButton = container.FindChildTraverse("ParticleRadioButton_" + i);
            radionButton.RemoveAndDeleteChildren();
        }
        particlePanelHub.RemoveAndDeleteChildren();
    }

}

function ShowPayBlock() {

    var button = $("#PayTriggerButton");
    var payPanelContainer = button.GetParent().GetParent().GetParent().FindChildTraverse("PayPanelContainer");

    var playerId = Players.GetLocalPlayer();
    var steam_id = Game.GetPlayerInfo(playerId).player_steamid;

    var vipValidDateUTC = CustomNetTables.GetTableValue("vipMap", "" + ConvertToSteamId32(steam_id)).validate_date;
    if (vipValidDateUTC != null && vipValidDateUTC != "") {

        var utcDate = new Date(vipValidDateUTC.replace(/-/g, '/'));
        var localOffset = (new Date()).getTimezoneOffset() * 60000;
        var localDate = new Date(utcDate.getTime() - localOffset);
        var localDateStr = getFormatDateStr(localDate);
        payPanelContainer.FindChildInLayoutFile("ValidDateLabel").text = $.Localize("#pass_expire") + localDateStr;
    }

    if (payPanelContainer.BHasClass("hidden")) {
        payPanelContainer.SetHasClass("hidden", false);
    }
    else {
        payPanelContainer.SetHasClass("hidden", true);
    }
}

function ShowSaveBlock(bReloadFlag) {

    var button = $("#SaveTriggerButton");
    var savePanelHub = button.GetParent().GetParent().GetParent().FindChild("SavePanelHub");

    var particleButton = $("#ParticleTriggerButton");
    var particlePanelHub = particleButton.GetParent().GetParent().GetParent().FindChild("ParticlePanelHub");


    var container = savePanelHub.FindChild("SavePanelContainer");
    //向服务器请求读取存档信息
    var playerId = Players.GetLocalPlayer();
    var steam_id = Game.GetPlayerInfo(playerId).player_steamid;
    steam_id = ConvertToSteamId32(steam_id);

    if (!container)  //如果不存在新建一个 
    {
        savePanelHub.BLoadLayoutSnippet("save_snippet_container");
        container = savePanelHub.FindChild("SavePanelContainer");
    }
    else //如果存在
    {
        if (container.BHasClass("hidden")) {
            container.SetHasClass("hidden", false);
        }
        else {
            if (!bReloadFlag) {
                container.SetHasClass("hidden", true);
            }

        }
    }

    for (var i = 1; i <= 5; i++) {

        var radionButton = container.FindChildTraverse("SaveRadioButton_" + i);
        radionButton.SetPanelEvent("onactivate", RecordSlotSelect(i));
        var radioBox = radionButton.FindChildrenWithClassTraverse("RadioBox")
        radionButton.FindChildrenWithClassTraverse("RadioBox")[0].SetHasClass("hidden", true)
    }

    //container.SetHasClass( "hidden", false ); //上蒙版

    var loadingPanel = container.FindChildTraverse("SaveLoadingPanel")
    loadingPanel.SetHasClass("hidden", false); //上蒙版

    $.AsyncWebRequest(serverAddress + 'loadgame?saver_steam_id=' + steam_id,
        {
            type: 'GET',
            success: function (resultJson) {
                var results = JSON.parse(resultJson);
                for (var i = 0; i < results.length; i++) {
                    var result = results[i];
                    var slot_index = result.slot_index;
                    var data = JSON.parse(result.json_data);
                    var radionButton = container.FindChildTraverse("SaveRadioButton_" + slot_index);
                    radionButton.json_data = result.json_data //数据存在按钮上
                    var detailPanel = radionButton.FindChild("DetailPanel_" + slot_index);
                    if (!detailPanel) //如果不存在新建一个
                    {
                        detailPanel = $.CreatePanel("Panel", radionButton, "DetailPanel_" + slot_index);
                        detailPanel.BLoadLayout("file://{resources}/layout/custom_game/tws_save_slot.xml", false, false);
                    }
                    detailPanel.FindChildInLayoutFile("HeroImage").heroname = data.saverHeroName
                    var difficultyText = "";
                    if (data.map_difficulty == 1) {
                        difficultyText = $.Localize("#game_difficulty_easy");
                    }
                    if (data.map_difficulty == 2) {
                        difficultyText = $.Localize("#game_difficulty_normal");
                    }
                    if (data.map_difficulty == 3) {
                        difficultyText = $.Localize("#game_difficulty_hard");
                    }
                    if (data.map_difficulty >= 4) {
                        difficultyText = $.Localize("#game_difficulty_trial");
                    }
                    detailPanel.FindChildInLayoutFile("difficulty_value").text = difficultyText
                    detailPanel.FindChildInLayoutFile("player_number_value").text = data.playerNumber //有效玩家数量
                    detailPanel.FindChildInLayoutFile("round_value").text = data.next_round
                    detailPanel.FindChildInLayoutFile("time_cost_value").text = FormatSeconds(data.nTimeCost)
                    detailPanel.FindChildInLayoutFile("avg_level_value").text = data.nHeroAvgLevel
                    detailPanel.FindChildInLayoutFile("avg_gold_value").text = data.nHeroAvgGold
                    container.FindChildInLayoutFile("EmptyMask_" + slot_index).SetHasClass("hidden", true); //隐藏蒙版
                }
                var loadingPanel = container.FindChildTraverse("SaveLoadingPanel")
                loadingPanel.SetHasClass("hidden", true); //取消主蒙版的遮蔽
            }
        });

    var playerId = Players.GetLocalPlayer();
    var steam_id = Game.GetPlayerInfo(playerId).player_steamid;
    var vipLevel = CustomNetTables.GetTableValue("vipMap", "" + ConvertToSteamId32(steam_id)).level;

    if (vipLevel >= 1 || particlePanelHub.saveBackDoor) {
        container.FindChildTraverse("SaveGameButton").enabled = true;
        container.FindChildTraverse("LoadGameButton").enabled = true;
    }
    else {
        container.FindChildTraverse("SaveGameButton").enabled = false;
        container.FindChildTraverse("LoadGameButton").enabled = false;
    }
}

function InitParticle() {
    for (var i = 1; i <= 10; i++) {
        var code_equip =
            "require 'vip/econ'\n" +
            "if Econ.OnEquip_" + particleNameMap[i - 1] + "_client then \n" +
            "Econ.OnEquip_" + particleNameMap[i - 1] + "_client( thisEntity ) \n" +
            "end";
        $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "scene_" + i, "model_" + i, "RunScriptCode", code_equip);
    }
}

function ReloadSavePanel(keys) {
    ShowSaveBlock(true); //重新加载
}

function ShowPassTooltip() {
    $.DispatchEvent("DOTAShowTitleTextTooltip", $("#PayTriggerButtonPanel"), "#pass_trigger_notice_title", "");
}

function HidePassTooltip() {
    $.DispatchEvent("DOTAHideTitleTextTooltip", $("#PayTriggerButtonPanel"));
}

function ShowSaveTooltip() {
    $.DispatchEvent("DOTAShowTitleTextTooltip", $("#SaveGameTriggerButtonPanel"), "#save_trigger_notice_title", "");
}

function HideSaveTooltip() {
    $.DispatchEvent("DOTAHideTitleTextTooltip", $("#SaveGameTriggerButtonPanel"));
}

(function () {
    GameEvents.Subscribe("ReloadSavePanel", ReloadSavePanel); //后台存档完毕，前台重新加载存档页面

    $.Schedule(8.0, ShowPassTooltip);

    $.Schedule(12.0, HidePassTooltip);

    $.Schedule(14.0, ShowSaveTooltip);

    $.Schedule(18.0, HideSaveTooltip);

})();

function OnParticleButtonPressed() {
    ShowParticleBlock();
}

Game.AddCommand("+CustomGameParticleButton", OnParticleButtonPressed, "", 0);