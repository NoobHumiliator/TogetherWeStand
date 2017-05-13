"use strict";

var particleNameMap = ["darkmoon","sakura_trail","rex","frull","black","lava_trail","paltinum_baby_roshan",
                       "devourling_gold","legion_wings","legion_wings_vip"];


var RecordSelect = ( function(particleName)
{
    return function()
    {  
        
         var button = $( "#ParticleTriggerButton" );
         var panelHub=button.GetParent().GetParent().GetParent().FindChild("ParticlePanelHub")
         panelHub.particleName=particleName; //记录下特效的名字
    }
});



function ShowParticleBlock()
{

    var button = $( "#ParticleTriggerButton" );
    var particlePanelHub=button.GetParent().GetParent().GetParent().FindChild("ParticlePanelHub");
    var container=particlePanelHub.FindChild("ParticlePanelContainer");
    $.DispatchEvent( "DOTAHideTitleTextTooltip",$("#ParticleTriggerButton") );

    if (!container)  //如果不存在新建一个
    {
        particlePanelHub.BLoadLayoutSnippet("snippet_container");
        container=particlePanelHub.FindChild("ParticlePanelContainer");
        for (var i = 1; i <= 10; i++) {
                var radionButton= container.FindChildTraverse( "ParticleRadioButton_"+i );
                var scenePanel=radionButton.BCreateChildren("<DOTAScenePanel style='width:290px;height:290px;' particleonly='false' id='scene_"+i+"' map='particle_model' camera='camera_"+i+"'/>");
                //var scenePanel=radionButton.BCreateChildren("<DOTAScenePanel style='width:300px;height:300px;' unit='faceless_rex' />");
                radionButton.SetPanelEvent( "onactivate", RecordSelect(particleNameMap[i-1]));
                radionButton.group="particleRadios"

                if (i<=5) //几个VIP的特效
                {
                    radionButton.enabled=false
                    if (particlePanelHub.hasOwnProperty("vipLevel")&&particlePanelHub.vipLevel!=null)
                    {
                        if  (particlePanelHub.vipLevel>=1)  //vip等级大于1 可以选上面的一排
                        {
                            radionButton.enabled=true
                        }                      
                    }
                }

                if (i>=6) //几个天梯等级的特效
                {
                    radionButton.enabled=false
                    if (particlePanelHub.hasOwnProperty("rank")&&particlePanelHub.rank!=null)
                    {
                        if  (particlePanelHub.rank<=15 && i<=6)  //前15
                        {
                            radionButton.enabled=true
                        }
                        if  (particlePanelHub.rank<=10 && i<=7)  //前10
                        {
                            radionButton.enabled=true
                        }
                        if  (particlePanelHub.rank<=5 && i<=8)  //前5
                        {
                            radionButton.enabled=true
                        }
                        if  (particlePanelHub.rank<=3 && i<=9)  //前3
                        {
                            radionButton.enabled=true
                        }
                        if  (particlePanelHub.rank<=1 && i<=10)  //前1
                        {
                            radionButton.enabled=true
                        }
                    }
                }
        }
        $.Schedule(1.0,InitParticle);
	}
    else  //如果存在就删除
    {
         for (var i = 1; i <= 10; i++) {
              var radionButton= container.FindChildTraverse( "ParticleRadioButton_"+i );
              radionButton.RemoveAndDeleteChildren();
        }
        particlePanelHub.RemoveAndDeleteChildren();
    }
        
}


function InitParticle()
{

     for (var i = 1; i <= 10; i++) {
            var code_equip =
                "require 'vip/econ'\n" +
                "if Econ.OnEquip_" + particleNameMap[i-1] + "_client then \n" +
                    "Econ.OnEquip_" + particleNameMap[i-1] + "_client( thisEntity ) \n" +
                "end";   
     $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "scene_"+i, "model_"+i, "RunScriptCode" , code_equip);         
    }
}


function NotifyVip(keys)
{
    var button = $( "#ParticleTriggerButton" );
    var particlePanelHub=button.GetParent().GetParent().GetParent().FindChild("ParticlePanelHub");
    particlePanelHub.vipLevel=keys.vipLevel;
}

function ShowTooltip()
{
    $.DispatchEvent("DOTAShowTitleTextTooltip",$("#ParticleTriggerButton"), "#particle_trigger_notice_title", "#particle_trigger_notice_detail");
}

function HideTooltip()
{
    $.DispatchEvent( "DOTAHideTitleTextTooltip",$("#ParticleTriggerButton") );
}



(function()
{
    GameEvents.Subscribe( "NotifyVip", NotifyVip );
   
    $.Schedule(8.0,ShowTooltip);

    $.Schedule(11.0,HideTooltip);

})();


function OnParticleButtonPressed()
{
    
    ShowParticleBlock();

}


Game.AddCommand( "+CustomGameParticleButton", OnParticleButtonPressed, "", 0 );