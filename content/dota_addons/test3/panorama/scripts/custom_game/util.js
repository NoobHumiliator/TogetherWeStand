"use strict";

var serverAddress = 'http://106.13.79.105:8090/'

var particleNameMap = [
    //1-5为天梯排名特效
    "legion_wings_vip", "legion_wings_pink", "legion_wings", "paltinum_baby_roshan", "lava_trail",
    //6 以后为PASS特效
    "rex", "frull", "black", "devourling_gold", "darkmoon",
    "rich", "sakura_trail", "ti6", "ti7", "ti8",
    "ti9", "winter18", "onibi", "sand", "frost"
]

//信使列表
var couriersList = ["beetle_bark", "beetle_jaws", "dark_moon", "desert_sand", "doomling",
    "drodo", "eimer", "faceless", "fezzle", "gingerbread",
    "golden_roshan", "golden_beetlejaws", "golden_doomling", "golden_greevil", "golden_huntling",
    "golden_krobeling", "golden_venoling", "hakobi", "huntling", "ice_roshan",
    "krobeling", "lava_roshan", "lockjaw", "murrissey", "nian",
    "onibi", "osky", "pholi", "platinum_roshan", "stumpy",
    "trapjaw", "mountain_yak", "venoling", "war_dog", "jade_roshan"
]


function GetRandomInt(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

var ShowAbilityTooltip = (function (ability) {
    return function () {
        $.DispatchEvent("DOTAShowAbilityTooltip", ability, ability.abilityname);
    }
});

var HideAbilityTooltip = (function (ability) {
    return function () {
        $.DispatchEvent("DOTAHideAbilityTooltip", ability);
    }
});

function ShowItemTooltip(itemImage) {
    $.DispatchEvent("DOTAShowAbilityTooltip", itemImage, itemImage.itemname)
}

function HideItemTooltip(itemImage) {
    $.DispatchEvent("DOTAHideAbilityTooltip", itemImage);
}

function FormatSeconds(value) {  //将秒数转为时分秒
    var theTime = parseInt(value);// 秒
    var theTime1 = 0;// 分
    var theTime2 = 0;// 小时
    if (theTime > 60) {
        theTime1 = parseInt(theTime / 60);
        theTime = parseInt(theTime % 60);
        if (theTime1 > 60) {
            theTime2 = parseInt(theTime1 / 60);
            theTime1 = parseInt(theTime1 % 60);
        }
    }
    var result = "" + parseInt(theTime) + "\"";
    if (theTime1 > 0) {
        result = "" + parseInt(theTime1) + "\'" + result;
    }
    if (theTime2 > 0) {
        result = "" + parseInt(theTime2) + ":" + result;
    }
    return result;
}

function ConvertToSteamid64(steamid32)  //32位转64位
{
    var steamid64 = '765' + (parseInt(steamid32) + 61197960265728).toString();
    return steamid64;
}

function ConvertToSteamId32(steamid64) {   //64位转32位
    return steamid64.substr(3) - 61197960265728;
}

function getFormatDateStr(date) {
    var Y = date.getFullYear();
    var M = date.getMonth() + 1;
    M = M < 10 ? '0' + M : M;
    var D = date.getDate();
    D = D < 10 ? '0' + D : D;
    var H = date.getHours();
    H = H < 10 ? '0' + H : H;
    var Mi = date.getMinutes();
    Mi = Mi < 10 ? '0' + Mi : Mi;
    var S = date.getSeconds();
    S = S < 10 ? '0' + S : S;
    return Y + '-' + M + '-' + D + ' ' + H + ':' + Mi + ':' + S;
}

const dotaHud = (() => {
    let panel = $.GetContextPanel();
    while (panel) {
        if (panel.id === "DotaHud") return panel;
        panel = panel.GetParent();
    }
})();


function FindDotaHudElement(id){
    var hudRoot;
    let panel = $.GetContextPanel();
    for(panel=$.GetContextPanel();panel!=null;panel=panel.GetParent()){
        hudRoot = panel;
    }
    var comp = hudRoot.FindChildTraverse(id);
    return comp;
}


//带回传的请求，每次调用id都增加1
function CreateEventRequestCreator(eventName) {
    var idCounter = 0;
    return function(data, callback) {
        var id = ++idCounter;
        data.id = id;
        GameEvents.SendCustomGameEventToServer(eventName, data);
        var listener = GameEvents.Subscribe(eventName, function(data) {
            if (data.id !== id) return;
            GameEvents.Unsubscribe(listener);
            callback(data)
        });
        return listener;
    }
}
