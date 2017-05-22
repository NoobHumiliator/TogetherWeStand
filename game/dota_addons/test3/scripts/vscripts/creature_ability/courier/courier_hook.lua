function HookItems( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
	local point = keys.target_points[ 1 ]
	local radius = ability:GetLevelSpecialValueFor( "radius", ( ability:GetLevel() - 1 ) )
  local drop_items=Entities:FindAllByClassnameWithin("dota_item_drop",point,radius)

  if #drop_items>0 then
     EmitSoundOn("Hero_Rattletrap.Hookshot.Fire", caster)
  end
  for _, drop_item in pairs(drop_items) do

      local projTable = {
        Target = drop_item,
        Source = caster,
        Ability = ability,
        EffectName = "particles/units/heroes/hero_rattletrap/rattletrap_hookshot.vpcf",
        bDodgeable = false,
        bProvidesVision = true,
        iMoveSpeed = 2000 ,--ability:GetSpecialValueFor("projectile_speed"), 
        vSpawnOrigin = caster:GetAbsOrigin()
      }
      ProjectileManager:CreateTrackingProjectile(projTable)
      local time=(point-caster:GetOrigin()):Length2D()/2000
             Timers:CreateTimer(time, 
              function()
                  local containedItem = drop_item:GetContainedItem()        
                  if caster:GetUnitName()=="npc_dota_courier" and caster.nControlledPickPlayerId  and  string.sub(containedItem:GetName(),1,20)~= "item_treasure_chest_" then --如果是信使，且不是宝箱
                     if containedItem:GetPurchaser()==nil then
                        local playerId=caster.nControlledPickPlayerId
                        local hero = PlayerResource:GetSelectedHeroEntity( playerId )
                          containedItem:SetPurchaser(hero)
                          caster:AddItem(containedItem)
                          --UTIL_Remove( containedItem )
                          UTIL_Remove( drop_item )
                       end
                  end      
              end)
   end
end

