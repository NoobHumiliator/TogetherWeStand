"use strict";

var particleNameMap = ["darkmoon", "sakura_trail", "rex", "frull", "black", "lava_trail", "paltinum_baby_roshan",
    "devourling_gold", "legion_wings", "legion_wings_vip"];

function ConfirmParticle()  //向Lua传递确认信息
{
    var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
    var panelHub = $("#ParticlePanelHub")

    GameEvents.SendCustomGameEventToServer("ConfirmParticle", { playerId: playerId, particleName: panelHub.particleName });

    var container = $("#ParticlePanelHub");

    /**
    for (var i = 1; i < 10; i++) {
       var radionButton= $( "#ParticleRadioButton_"+i);
       var scenePanel=radionButton.FindChild ("scene_"+i);
       scenePanel.RemoveAndDeleteChildren()
    }
    **/
    container.RemoveAndDeleteChildren()
}

function CancleParticle()  //取消粒子特效，向Lua传递
{
    var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
    GameEvents.SendCustomGameEventToServer("CancleParticle", { playerId: playerId });

    var container = $("#ParticlePanelHub");

    container.RemoveAndDeleteChildren();
    /**
      for (var i = 1; i < 10; i++) {
         var radionButton= $( "#ParticleRadioButton_"+i);
         var scenePanel=radionButton.FindChild ("scene_"+i);
         scenePanel.RemoveAndDeleteChildren()
      }
     **/
}

function ShowParticleTooltip(index) {
    var title = "#particle_title_" + particleNameMap[index - 1];
    var detail = "#particle_detail_" + particleNameMap[index - 1];
    $.DispatchEvent("DOTAShowTitleTextTooltip", $("#ParticleRadioButton_" + index), title, detail);
    $.DispatchEvent("DOTAShowTitleTextTooltip", $("#ParticleRadioButton_" + index), title, detail);
}

function HideParticleTooltip(index) {
    $.DispatchEvent("DOTAHideTitleTextTooltip", $("#ParticleRadioButton_" + index));
}

(function () {
    var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
    var heroIndex = Players.GetPlayerHeroEntityIndex(playerId);
    var heroName = Entities.GetUnitName(heroIndex)
    //$.Msg(heroName)

    /**
    for (var i = 1; i <= 10; i++) {
        var radionButton= $( "#ParticleRadioButton_"+i );
        var scenePanel=radionButton.BCreateChildren("<DOTAScenePanel style='width:290px;height:290px;' id='scene_"+i+"' map='particle_model' camera='camera_"+i+"'/>");
        //var scenePanel=radionButton.BCreateChildren("<DOTAScenePanel style='width:300px;height:300px;' unit='faceless_rex' />");
        radionButton.SetPanelEvent( "onactivate", RecordSelect(particleNameMap[i-1]));
        radionButton.group="particleRadios"      
    }
    **/
    //开始隐藏起来
    //var container= $( "#ParticlePanelContainer");
    //container.invisible=true;
    //container.SetHasClass("Hidden", true);

})();