function ShowItemTooltip (itemImage) {
    $.DispatchEvent("DOTAShowAbilityTooltip",itemImage,itemImage.itemname)
}

function HideItemTooltip (itemImage) {
     $.DispatchEvent("DOTAHideAbilityTooltip",itemImage);
}



function RefreshQuestData(data){

     $.Msg(data)
    var panleId=data.name
    var panleSvalue=data.svalue
    var panleEvalue=data.evalue
    var remark=data.remark
    
    //var panleText=$.Localize(data.text)+"("+panleSvalue+"/"+panleEvalue+")"
    //$.Msg($.Localize("#tws_quest_prep_time"))
    var questPanle=$('#QuestPanel').FindChild(panleId)
    var valuePercent=parseInt(panleSvalue)/parseInt(panleEvalue)*100;
    if(questPanle!=null){
        sliderPanle=questPanle.GetChild(0);
        sliderPanle.GetChild(0).style.width=valuePercent.toString()+"%"
        sliderPanle.GetChild(1).style.width=(100-valuePercent).toString()+"%"
        questPanle.GetChild(1).GetChild(0).text=panleText
         if (remark!=null)
         {
             questPanle.GetChild(1).GetChild(0).SetDialogVariableInt( "remark", remark);
         }
        var panleText=$.Localize(data.text,questPanle.GetChild(1).GetChild(0))+"("+panleSvalue+"/"+panleEvalue+")"
        questPanle.GetChild(1).GetChild(0).text=panleText
    }
}

function CreatQuest(data) {
        //$.Msg("CreateQuest")
        //$.Msg(data)
        newPanel = $.CreatePanel('Panel', $('#QuestPanel'),data.name);
        newPanel.BLoadLayoutSnippet("QuestLine");
        newPanel.AddClass("Panle_MarginStyle")
}


function CreatAchQuest(data) {  //成就特殊奖励UI
        $.Msg("CreateAchQuest")
        $.Msg(data)
        var itemName=data.itemname
        newPanel = $.CreatePanel('Panel', $('#QuestPanel'),data.name);
        newPanel.BLoadLayoutSnippet("AchievementLine");
        newPanel.AddClass("Panle_MarginStyle")
        var itemImage= newPanel.GetChild(1).GetChild(1)
        if (itemImage!=null&&itemName!=null)
        {
            $.Msg("itemName"+itemName)
            itemImage.itemname=itemName;
        }
        //itemImage.SetPanelEvent( "onmouseover", ShowItemTooltip (itemImage) );
        //itemImage.SetPanelEvent( "onmouseout",  HideItemTooltip (itemImage) );
}


function RefreshAchQuestData(data){

    $.Msg("RefreshAchQuest")
    $.Msg(data)
    var panleId=data.name
    var panleSvalue=data.svalue
    var panleEvalue=data.evalue
    
    var questPanle=$('#QuestPanel').FindChild(panleId)
    var valuePercent=parseInt(panleSvalue)/parseInt(panleEvalue)*100;
    if(questPanle!=null){
        sliderPanle=questPanle.GetChild(0);
        sliderPanle.GetChild(0).style.width=valuePercent.toString()+"%"
        sliderPanle.GetChild(1).style.width=(100-valuePercent).toString()+"%"
        var panleText=$.Localize(data.text,questPanle.GetChild(1).GetChild(2))+"("+panleSvalue+"/"+panleEvalue+")"
        questPanle.GetChild(1).GetChild(2).text=panleText
    }
}


function RemoveQuestPUI(data){
    var RemovePanle=$('#QuestPanel').FindChild(data.name)
    RemovePanle.deleted = true;
    RemovePanle.DeleteAsync(0);
}

(function(){ 
    GameEvents.Subscribe( "createquest", CreatQuest);
    GameEvents.Subscribe( "createachquest", CreatAchQuest);
    GameEvents.Subscribe( "refreshquestdata", RefreshQuestData);
    GameEvents.Subscribe( "refreshachquestdata", RefreshAchQuestData);
    GameEvents.Subscribe( "removequestpui", RemoveQuestPUI);
})();

