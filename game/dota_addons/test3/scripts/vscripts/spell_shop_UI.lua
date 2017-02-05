alreadyCached = {} 

pairedAbility = {shredder_chakram="shredder_return_chakram", morphling_replicate="morphling_morph_replicate", elder_titan_ancestral_spirit="elder_titan_return_spirit" , 
phoenix_icarus_dive="phoenix_icarus_dive_stop" , phoenix_sun_ray="phoenix_sun_ray_stop",phoenix_fire_spirits="phoenix_launch_fire_spirit",abyssal_underlord_dark_rift="abyssal_underlord_cancel_dark_rift",
alchemist_unstable_concoction="alchemist_unstable_concoction_throw",naga_siren_song_of_the_siren="naga_siren_song_of_the_siren_cancel",rubick_telekinesis="rubick_telekinesis_land",
bane_nightmare="bane_nightmare_end",ancient_apparition_ice_blast="ancient_apparition_ice_blast_release",lone_druid_true_form="lone_druid_true_form_druid",shredder_chakram_2="shredder_return_chakram_2",nyx_assassin_burrow="nyx_assassin_unburrow",
wisp_tether="wisp_tether_break",morphling_morph_agi="morphling_morph",morphling_morph_str="morphling_morph"}
brokenModifierCounts = {
        modifier_shadow_demon_demonic_purge_charge_counter = 3,
        modifier_bloodseeker_rupture_charge_counter = 2,
        modifier_earth_spirit_stone_caller_charge_counter = 6,
        modifier_ember_spirit_fire_remnant_charge_counter = 3
    }
brokenModifierAbilityMap = {
        shadow_demon_demonic_purge = "modifier_shadow_demon_demonic_purge_charge_counter",
        bloodseeker_rupture = "modifier_bloodseeker_rupture_charge_counter",
        earth_spirit_stone_caller="modifier_earth_spirit_stone_caller_charge_counter",
        ember_spirit_fire_remnant="modifier_ember_spirit_fire_remnant_charge_counter"  
   }
noReturnAbility = {    --不退回升级点数的技能
        troll_warlord_whirling_axes_ranged = true,
        troll_warlord_whirling_axes_melee = true,
        lone_druid_savage_roar_bear = true,
        phoenix_sun_ray_toggle_move = true,
        morphling_hybrid = true,
        morphling_morph_agi = true,
        morphling_morph_str = true
    }

meleeMap = {
    -- Remap troll ulty
    troll_warlord_berserkers_rage = 'troll_warlord_berserkers_rage_melee'
}

manualActivate = {
    keeper_of_the_light_blinding_light_tws = true,
    keeper_of_the_light_recall_tws = true
}

local unitList = LoadKeyValues('scripts/npc/npc_units_custom.txt')
-- Contains info on heroes
local heroListKV = LoadKeyValues('scripts/npc/npc_heroes.txt')

local meleeList = {}
for heroName, values in pairs(heroListKV) do
    if heroName ~= 'Version' and heroName ~= 'npc_dota_hero_base' then
        if values.AttackCapabilities == 'DOTA_UNIT_CAP_MELEE_ATTACK' then
            meleeList[heroName] = true
        end
    end
end


-- Tells you if a given heroName is melee or not
local function isMeleeHero(heroName)
    if meleeList[heroName] then
        return true
    end

    return false
end


local function unitExists(unitName)
    -- Check if the unit exists
    if unitList[unitName] then return true end
    return false
end

function CHoldoutGameMode:HeroListRefill()
	self._vHeroList={}
	local heroListKV = LoadKeyValues("scripts/kv/npc_heroes_precache.txt")
	for k, v in pairs( heroListKV ) do
		if type( v ) == "table" and v.Ability1 then
			for i = 1,17 do
				local a = "Ability" .. tostring(i)
				if v[a] ~= nil then
					self._vHeroList[ v[a] ] = k
				end
			end
		end
	end
end




function CHoldoutGameMode:AddAbility(keys)
  --PrintTable(keys)
	if PlayerResource:HasSelectedHero( keys.playerId ) then
		local hero = PlayerResource:GetSelectedHeroEntity( keys.playerId )
		local abilityName=keys.abilityName
		  if hero then
		  	 if keys.enough==1 then
	           if isMeleeHero(hero:GetUnitName()) and meleeMap[abilityName] then
	               abilityName = meleeMap[abilityName]
	           end
               hero:AddAbility(abilityName)
               if pairedAbility[abilityName]~=nil then
                  hero:AddAbility(pairedAbility[abilityName])
                  if pairedAbility[abilityName]=="nyx_assassin_unburrow" then
                  	hero:FindAbilityByName("nyx_assassin_unburrow"):SetLevel(1)  --默认升一级
                  end
               end

               if manualActivate[abilityName] then  --激活光法的两个技能
                 local ab = hero:FindAbilityByName(abilityName)
                 if ab then
                    ab:SetActivated(true)
                 end
               end
               ------------------------------------------------
               if  CHoldoutGameMode._vHeroList[abilityName]~=nil then
                if alreadyCached[ CHoldoutGameMode._vHeroList[abilityName]]==true then
                else				
                  alreadyCached[ CHoldoutGameMode._vHeroList[abilityName]] = true
                  print('Precaching unit: '.. CHoldoutGameMode._vHeroList[abilityName]) 
                  if unitExists('npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName]) then     
                    PrecacheUnitByNameAsync('npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName], function() end)
                  else
                    print('Failed to precache unit: npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName])
                  end
                end
              else
                PrecacheUnitByNameAsync('npc_precache_'..abilityName, function() end)    --自定义的技能需要单独加载         
              end 
	           ------------------------------------------------------ 
               local p = hero:GetAbilityPoints()
               hero:SetAbilityPoints(p-keys.abilityCost)
               local ability = hero:FindAbilityByName(abilityName)
		           ability:SetLevel(1)
		           ability:SetHidden(false)
               CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"UpdateAbilityList", keys)
               EmitSoundOn("General.Buy",PlayerResource:GetPlayer(keys.playerId))
               if brokenModifierAbilityMap[abilityName]~=nil then
	               local modifier = hero:FindModifierByName(brokenModifierAbilityMap[abilityName])
			       if modifier then
			       	    local stack= brokenModifierCounts[brokenModifierAbilityMap[abilityName]]
			            modifier:SetStackCount(stack)
			       end
		       end
             else
               Notifications:Bottom(keys.playerId, {text="#not_enough_ability_points", duration=2, style={color="Red"}})
               EmitSoundOn("General.Cancel",PlayerResource:GetPlayer(keys.playerId))
             end
		  end
    ReportHeroAbilities(hero)
	end
end



function CHoldoutGameMode:LevelUpAttribute(keys)
  if PlayerResource:HasSelectedHero( keys.playerId ) then
    local hero = PlayerResource:GetSelectedHeroEntity( keys.playerId )
    keys.heroName=false
      if hero then
         if keys.enough==1 then           
             if hero:HasAbility("attribute_bonus_lua")  then
                local level=hero:FindAbilityByName("attribute_bonus_lua"):GetLevel()
                level=level+1
                hero:FindAbilityByName("attribute_bonus_lua"):SetLevel(level)
             else
                hero:AddAbility("attribute_bonus_lua")
                hero:FindAbilityByName("attribute_bonus_lua"):SetLevel(1)  --默认升一级
             end       
             ------------------------------------------------------ 
             local p = hero:GetAbilityPoints()
             hero:SetAbilityPoints(p-1)
             CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"UpdateAbilityList", keys)
             EmitSoundOn("General.Buy",PlayerResource:GetPlayer(keys.playerId))       
         else
           Notifications:Bottom(keys.playerId, {text="#not_enough_ability_points", duration=2, style={color="Red"}})
           EmitSoundOn("General.Cancel",PlayerResource:GetPlayer(keys.playerId))
         end
      end
  end
end


function CHoldoutGameMode:PointToGold(keys)
  if PlayerResource:HasSelectedHero( keys.playerId ) then
    local hero = PlayerResource:GetSelectedHeroEntity( keys.playerId )
    keys.heroName=false
      if hero then
         if keys.enough==1 then
             hero:ModifyGold(1500,true, 0)
             local p = hero:GetAbilityPoints()
             hero:SetAbilityPoints(p-1)
             CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"UpdateAbilityList", keys)                
             EmitSoundOn("General.CoinsBig",PlayerResource:GetPlayer(keys.playerId))       
         else
           Notifications:Bottom(keys.playerId, {text="#not_enough_ability_points", duration=2, style={color="Red"}})
           EmitSoundOn("General.Cancel",PlayerResource:GetPlayer(keys.playerId))
         end
      end
  end
end


function CHoldoutGameMode:RemoveAbility(keys)
	if PlayerResource:HasSelectedHero( keys.playerId ) then
		local hero = PlayerResource:GetSelectedHeroEntity( keys.playerId )
		  if hero then
		  	 local ability = hero:FindAbilityByName(keys.abilityName)
		  	  if ability then
		  	    local abilityLevel=ability:GetLevel()
		  	    if noReturnAbility[ability:GetAbilityName()] ~= nil then  --同时升级的技能不退技能点
                  abilityLevel=1
            end
		  	    local pointsReturn=keys.abilityCost+abilityLevel-1
            local expense=PlayerResource:GetLevel(keys.playerId)*pointsReturn*30
	             if(hero:GetGold() >= expense) then
	               local abilityLevel=ability:GetLevel()
	               local modifiers=hero:FindAllModifiers()
	                for _,modifier in pairs(modifiers) do
		              if modifier:GetAbility()==ability then
		               modifier:Destroy()
		              end
		            end
                print(hero:GetUnitName().." removing ability: ".. keys.abilityName)
		            hero:RemoveAbility(keys.abilityName)
		             if pairedAbility[keys.abilityName]~=nil then                      
                      hero:RemoveAbility(pairedAbility[keys.abilityName])
                      print(hero:GetUnitName().." removing pairs ability: ".. keys.abilityName)
                 end
		            local p = hero:GetAbilityPoints()
                    hero:SetAbilityPoints(p + pointsReturn)
	                hero:SpendGold(expense, DOTA_ModifyGold_Unspecified)
	                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"UpdatePlayerAbilityList",keys)
	                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"UpdateAbilityList", {heroName=false,playerId=keys.playerId})
	                EmitSoundOn("compendium_points",PlayerResource:GetPlayer(keys.playerId))
		          else
		                Notifications:Bottom(keys.playerId, {text="#you_need", duration=3, style={color="Red"}})
                    Notifications:Bottom(keys.playerId, {text=tostring(expense).." ", duration=3, style={color="Red"}, continue=true})
                    Notifications:Bottom(keys.playerId, {text="#gold_to_sell_this_spell", duration=3, style={color="Red"}, continue=true})
                    EmitSoundOn("General.Cancel",PlayerResource:GetPlayer(keys.playerId))
	              end
		      end
		   end
	 end
end


