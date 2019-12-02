var iIndexTip = 1; 
var LOADINGTIP_CHANGE_DELAY = 6;

var availableIndexTable = 
[
    1,
    2,
    3,
    4,
]

function NextTip_Delay()
{
    NextTip();
    $.Schedule(LOADINGTIP_CHANGE_DELAY, NextTip_Delay);
}

function RandomTipIndex()
{
    var randomIndex = Math.floor(Math.random()*availableIndexTable.length);
    while(availableIndexTable[(randomIndex).toString()] == iIndexTip)
    {
        
        randomIndex = Math.floor(Math.random()*availableIndexTable.length);
    }
    return availableIndexTable[(randomIndex).toString()];
}

function NextTip()
{
    iIndexTip = RandomTipIndex();
    var sTip = "#LoadingTip_" + iIndexTip;
    $("#TipLabel").text=$.Localize(sTip);
}

(function()
{
    iIndexTip = RandomTipIndex();
    var sTip = "#LoadingTip_" + iIndexTip;
    $("#TipLabel").text=$.Localize(sTip);
    NextTip_Delay();
})();