function RefreshQuestData(data) {

    var panleId = data.name
    var panleSvalue = data.svalue
    var panleEvalue = data.evalue
    var remark = data.remark

    var questPanle = $('#QuestPanel').FindChild(panleId)
    var valuePercent = parseInt(panleSvalue) / parseInt(panleEvalue) * 100;
    if (questPanle != null) {
        sliderPanle = questPanle.GetChild(0);
        sliderPanle.GetChild(0).style.width = valuePercent.toString() + "%"
        sliderPanle.GetChild(1).style.width = (100 - valuePercent).toString() + "%"
        questPanle.GetChild(1).GetChild(0).text = panleText
        if (remark != null) {
            questPanle.GetChild(1).GetChild(0).SetDialogVariableInt("remark", remark);
        }
        var panleText = $.Localize(data.text, questPanle.GetChild(1).GetChild(0)) + "(" + panleSvalue + "/" + panleEvalue + ")"
        questPanle.GetChild(1).GetChild(0).text = panleText
    }
}

function CreatQuest(data) {
    newPanel = $.CreatePanel('Panel', $('#QuestPanel'), data.name);
    newPanel.BLoadLayoutSnippet("QuestLine");
    newPanel.AddClass("Panle_MarginStyle")
}


function CreatAchQuest(data) {  //成就特殊奖励UI
    var itemName = data.itemname
    var newPanel = $.CreatePanel('Panel', $('#QuestPanel'), data.name);
    newPanel.BLoadLayoutSnippet("AchievementLine");
    newPanel.AddClass("Panle_MarginStyle")
    var itemImage = newPanel.GetChild(1).GetChild(1)
    if (itemImage != null && itemName != null) {
        itemImage.itemname = itemName;
    }
}

var index = 1;  //全局计数器

function CreatAffixes(data) {  //词缀

    var affixesList = data.list
    var newPanel = $.CreatePanel('Panel', $('#QuestPanel'), data.name);
    newPanel.BLoadLayoutSnippet("AffixesLine");
    newPanel.AddClass("Panle_MarginStyle")
    index = 1;

    for (var i in affixesList) {
        $.Schedule((i - 1) * 1.5, function () {
            var affixAbilityName = affixesList[index];
            var imageId = "affix_id_" + index;
            var offset = 310 - index * 50;  //调整横向位置  
            var abilityImage = $.CreatePanel("DOTAAbilityImage", newPanel, imageId);
            //$.Msg(affixAbilityName)
            abilityImage.abilityname = affixAbilityName;  //abilityname 全小写
            abilityImage.SetHasClass("AbilityImage", true);
            abilityImage.style.position = offset + "px 0 0 0";
            abilityImage.SetPanelEvent("onmouseover", ShowAbilityTooltip(abilityImage));
            abilityImage.SetPanelEvent("onmouseout", HideAbilityTooltip(abilityImage));
            index++;
        })
    }
}


function RefreshAchQuestData(data) {

    var panleId = data.name
    var panleSvalue = data.svalue
    var panleEvalue = data.evalue

    var questPanle = $('#QuestPanel').FindChild(panleId)
    var valuePercent = parseInt(panleSvalue) / parseInt(panleEvalue) * 100;
    if (questPanle != null) {
        sliderPanle = questPanle.GetChild(0);
        sliderPanle.GetChild(0).style.width = valuePercent.toString() + "%"
        sliderPanle.GetChild(1).style.width = (100 - valuePercent).toString() + "%"
        var panleText = $.Localize(data.text, questPanle.GetChild(1).GetChild(2)) + "(" + panleSvalue + "/" + panleEvalue + ")"
        questPanle.GetChild(1).GetChild(2).text = panleText
    }
}


function RemoveQuestPUI(data) {
    //$.Msg(data.name+"data name")
    var RemovePanle = $('#QuestPanel').FindChild(data.name)
    RemovePanle.deleted = true;
    RemovePanle.DeleteAsync(0);
}

(function () {
    GameEvents.Subscribe("createquest", CreatQuest);
    GameEvents.Subscribe("createachquest", CreatAchQuest);
    GameEvents.Subscribe("createaffixes", CreatAffixes);
    GameEvents.Subscribe("refreshquestdata", RefreshQuestData);
    GameEvents.Subscribe("refreshachquestdata", RefreshAchQuestData);
    GameEvents.Subscribe("removequestpui", RemoveQuestPUI);
})();