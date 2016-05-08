alreadyCached = {} 

pairedAbility = {shredder_chakram="shredder_return_chakram", morphling_replicate="morphling_morph_replicate", elder_titan_ancestral_spirit="elder_titan_return_spirit" , 
phoenix_icarus_dive="phoenix_icarus_dive_stop" , phoenix_sun_ray="phoenix_sun_ray_stop",   phoenix_fire_spirits="phoenix_launch_fire_spirit"}

local unitList = LoadKeyValues('scripts/npc/npc_units_custom.txt')





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
			for i = 1,7 do
				local a = "Ability" .. tostring(i)
				if v[a] ~= nil then
					self._vHeroList[ v[a] ] = k
				end
			end
		end
	end
end




function CHoldoutGameMode:AddAbility(keys)
	if PlayerResource:HasSelectedHero( keys.playerId ) then
		local hero = PlayerResource:GetSelectedHeroEntity( keys.playerId )
		local abilityName=keys.abilityName
		  if hero then
		  	 if keys.enough==1 then
               hero:AddAbility(keys.abilityName)
               if pairedAbility[keys.abilityName]~=nil then
                  hero:AddAbility(pairedAbility[keys.abilityName])
               end
               ------------------------------------------------
               if  CHoldoutGameMode._vHeroList[abilityName]~=nil then
		          if alreadyCached[ CHoldoutGameMode._vHeroList[abilityName]]==true then 
			        else				
                      alreadyCached[ CHoldoutGameMode._vHeroList[abilityName]] = true
                      --print('Precaching unit: '.. CHoldoutGameMode._vHeroList[abilityName]) 
                      if unitExists('npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName]) then     
                        PrecacheUnitByNameAsync('npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName], function() end)
                       else
                        --print('Failed to precache unit: npc_precache_'.. CHoldoutGameMode._vHeroList[abilityName])
                      end
                   end
                else
                PrecacheUnitByNameAsync('npc_precache_'..abilityName, function() end)    --自定义的技能需要单独加载         
               end 
	           ------------------------------------------------------ 
               local p = hero:GetAbilityPoints()
               hero:SetAbilityPoints(p-keys.abilityCost)
               local ability = hero:FindAbilityByName(keys.abilityName)
		       ability:SetLevel(1)	
               CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"UpdateAbilityList", keys)
               EmitSoundOn("General.Buy",PlayerResource:GetPlayer(keys.playerId))
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
		            hero:RemoveAbility(keys.abilityName)
		             if pairedAbility[keys.abilityName]~=nil then
                      hero:RemoveAbility(pairedAbility[keys.abilityName])
                     end
		            local p = hero:GetAbilityPoints()
                    hero:SetAbilityPoints(p + pointsReturn)
	                hero:SpendGold(expense, DOTA_ModifyGold_Unspecified)
	                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"UpdatePlayerAbilityList",keys)
	                CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.playerId),"UpdateAbilityList", {heroName=false,playerId=keys.playerId})
	                EmitSoundOn("compendium_points",PlayerResource:GetPlayer(keys.playerId))
		          else
		            Notifications:Bottom(keys.playerId, {text="#you_need", duration=3, style={color="Red"}})
                    Notifications:Bottom(keys.playerId, {text=tostring(expense), duration=3, style={color="Red"}, continue=true})
                    Notifications:Bottom(keys.playerId, {text="#gold_to_sell_this_spell", duration=3, style={color="Red"}, continue=true})
                    EmitSoundOn("General.Cancel",PlayerResource:GetPlayer(keys.playerId))
	              end
		      end
		   end
	 end
end


