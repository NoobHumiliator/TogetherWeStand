"use strict";

var particleNameMap = ["darkmoon", "sakura_trail", "rex", "frull", "black", "lava_trail", "paltinum_baby_roshan",
    "devourling_gold", "legion_wings", "legion_wings_vip"];

function ConfirmParticle()  //向Lua传递确认信息
{
    var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
    var panelHub = $("#ParticlePanelHub")

    GameEvents.SendCustomGameEventToServer("ConfirmParticle", { playerId: playerId, particleName: panelHub.particleName });

    var container = $("#ParticlePanelHub");
    container.RemoveAndDeleteChildren()
}

function CancleParticle()  //取消粒子特效，向Lua传递
{
    var playerId = Game.GetLocalPlayerInfo().player_id;     //玩家ID
    GameEvents.SendCustomGameEventToServer("CancleParticle", { playerId: playerId });

    var container = $("#ParticlePanelHub");
    container.RemoveAndDeleteChildren();
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
    
})();