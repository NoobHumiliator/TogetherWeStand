//保证玩家无法选取 其他玩家的信使


function OnUpdateSelectedUnit()
{    
     var units = Players.GetSelectedEntities(Players.GetLocalPlayer());
     var tempGroup = []
     var includeCourier = false

     //注意此处写法 避免进入死循环
     if (units.length>1)
     {
        //如果包含其他玩家信使
        for (var i = units.length - 1; i >= 0; i--) {
           if  (Entities.GetPlayerOwnerID( units[i] ) != Players.GetLocalPlayer())
           {
              includeCourier=true
           }
        }

        //排除信使再做一次选取
        if (includeCourier){
           for (var i = units.length - 1; i >= 0; i--) {
               if  (Entities.GetPlayerOwnerID( units[i] ) == Players.GetLocalPlayer())
               {
                  tempGroup.push(units[i])
               }
            }
            if (tempGroup.length>0) {
               GameUI.SelectUnit( tempGroup[0], false )
               for (var i = tempGroup.length - 1; i >= 1; i--) {
                 GameUI.SelectUnit( tempGroup[i], true )
               }
            } else {
              //如果无单位可选，直接选中英雄
              GameUI.SelectUnit( Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer()), false )
            }
        }
    }
}

(function () {

    // Built-In Dota client events
    GameEvents.Subscribe( "dota_player_update_selected_unit", OnUpdateSelectedUnit );
   
})();