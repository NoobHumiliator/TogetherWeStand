
function RefreshQuestData(data){
    var panleId=data.name
    var panleSvalue=data.svalue
    var panleEvalue=data.evalue
    var panleText=$.Localize(data.text)+"("+panleSvalue+"/"+panleEvalue+")"
    var questPanle=$('#QuestPanel').FindChild(panleId)
    var valuePercent=parseInt(parseInt(panleSvalue)/parseInt(panleEvalue)*100)
    if(questPanle!=null){
        sliderPanle=questPanle.GetChild(0);
        sliderPanle.GetChild(0).style.width=valuePercent.toString()+"%"
        sliderPanle.GetChild(1).style.width=(100-valuePercent).toString()+"%"
        questPanle.GetChild(1).GetChild(0).text=panleText
    }
}

function CreatQuest(data) {
        $.Msg("CreateQuest")
        $.Msg(data)
        newPanel = $.CreatePanel('Panel', $('#QuestPanel'),data.name);
        newPanel.BLoadLayoutSnippet("QuestLine");
        newPanel.AddClass("Panle_MarginStyle")
}

function RemoveQuestPUI(data){
    var RemovePanle=$('#QuestPanel').FindChild(data.name)
    RemovePanle.deleted = true;
    RemovePanle.DeleteAsync(0);
 
}

(function(){ 
    GameEvents.Subscribe( "createquest", CreatQuest);
    GameEvents.Subscribe( "refreshquestdata", RefreshQuestData);
    GameEvents.Subscribe( "removequestpui", RemoveQuestPUI);
})();


