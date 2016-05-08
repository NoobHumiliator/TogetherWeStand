
if CHoldoutGameMode == nil then
	_G.CHoldoutGameMode = class({}) 	
end

testMode=false --减少刷兵间隔，增加初始金钱
testMode=true --减少刷兵间隔，增加初始金钱



require( "holdout_game_round" )
require( "holdout_game_spawner" )
require( "util" )
require( "timers")
require( "spell_shop_UI")
require( "loot_controller" )
require( "difficulty_select_UI")
require( "global_setting")
require( "game_functions")
require( "utility_functions" )
require( "libraries/notifications")
require( "item_ability/damage_filter")

-- Precache resources
-- Actually make the game mode when we activate
function Activate()
	CHoldoutGameMode:InitGameMode()
end

function Precache( context )
	PrecacheResource( "particle", "particles/items_fx/aegis_respawn.vpcf", context )	
	PrecacheResource( "particle", "particles/neutral_fx/roshan_spawn.vpcf", context )	
	PrecacheResource( "particle", "particles/items2_fx/veil_of_discord.vpcf", context )
	PrecacheResource( "particle_folder", "particles/frostivus_gameplay", context )
	PrecacheResource( "sound_folder", "sounds/weapons/creep/neutral", context )
	PrecacheItemByNameSync( "item_tombstone", context )
	PrecacheItemByNameSync( "item_bag_of_gold", context )
	PrecacheItemByNameSync( "item_skysong_blade", context )
	PrecacheItemByNameSync( "item_slippers_of_halcyon", context )
	PrecacheItemByNameSync( "item_greater_clarity", context )
	PrecacheItemByNameSync( "item_unholy", context )
	PrecacheItemByNameSync( "item_fallen_sword", context )
	PrecacheUnitByNameAsync('npc_dota_tiny_1',function() end)
end



function CHoldoutGameMode:InitGameMode()

    GameRules:GetGameModeEntity().CHoldoutGameMode = self
    
	Timers:start()
	LootController:ReadConfigration() 
	self.startflag=0 
	self.loseflag=0 
	self.last_live=3
	self._nRoundNumber = 1
	self._currentRound = nil
	self._flLastThinkGameTime = nil
	self.enchantress_already_die_flag=0
	self:_ReadGameConfiguration()
	self.itemSpawnIndex = 1
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	GameRules:SetHeroRespawnEnabled( true )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 35.0 )
	if testMode then
	  GameRules:SetPreGameTime( 1.0 )
	  GameRules:SetGoldTickTime( 0.5 )
	  GameRules:SetGoldPerTick( 10000 )
	  else
	  GameRules:SetGoldTickTime( 60.0 )
	  GameRules:SetGoldPerTick( 0 )
	  GameRules:SetPreGameTime( 15.0 )
    end
	GameRules:SetPostGameTime( 10.0 )
	GameRules:SetTreeRegrowTime( 35.0 )
	GameRules:SetHeroMinimapIconScale( 0.7 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 80 )
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( xpTable )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	-- Custom console commands
	Convars:RegisterCommand( "holdout_test_round", function(...) return self:_TestRoundConsoleCommand( ... ) end, "Test a round of holdout.", FCVAR_CHEAT )
    --UI交互
    CustomGameEventManager:RegisterListener("AddAbility", Dynamic_Wrap(CHoldoutGameMode, 'AddAbility'))
    CustomGameEventManager:RegisterListener("RemoveAbility", Dynamic_Wrap(CHoldoutGameMode, 'RemoveAbility'))
    CustomGameEventManager:RegisterListener("SelectDifficulty",Dynamic_Wrap(CHoldoutGameMode, 'SelectDifficulty'))

	-- Hook into game events allowing reload of functions at run time
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameMode, "OnNPCSpawned" ), self )
	--ListenToGameEvent( "npc_replaced", Dynamic_Wrap( CHoldoutGameMode, "OnNPCReplaced" ), self )
	--ListenToGameEvent( "dota_player_used_ability", Dynamic_Wrap( CHoldoutGameMode, "OnUseAbility" ), self )
	ListenToGameEvent( "player_reconnected", Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerReconnected' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHoldoutGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHoldoutGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( CHoldoutGameMode, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap(CHoldoutGameMode, "OnHeroLevelUp"), self)
	ListenToGameEvent( "dota_item_purchased", Dynamic_Wrap(CHoldoutGameMode, "OnItemPurchased"), self)

    --读取spell shop UI的kv内容
	self.HeroesKV = LoadKeyValues("scripts/kv/spell_shop_ui_herolist.txt")
    self.AbilitiesKV = LoadKeyValues("scripts/kv/spell_shop_ui_abilities.txt")
    self.AbilitiesCostKV = LoadKeyValues("scripts/kv/spell_shop_ui_abilities_cost.txt")
    
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(CHoldoutGameMode, "DamageFilter"), self)
	GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(CHoldoutGameMode, "ModifyGoldFilter"), self)
	GameRules:GetGameModeEntity():SetContextThink( "globalthink0",function() return self:OnThink() end , 1.0)
	--self._vHeroList={}
    self:CreateNetTablesSettings()
    self:HeroListRefill()
end


-- Read and assign configurable keyvalues if applicable
function CHoldoutGameMode:_ReadGameConfiguration()
	local kv = LoadKeyValues( "scripts/maps/" .. GetMapName() .. ".txt" )
	kv = kv or {} -- Handle the case where there is not keyvalues file

	self._bAlwaysShowPlayerGold = kv.AlwaysShowPlayerGold or false
	self._bRestoreHPAfterRound = kv.RestoreHPAfterRound or false
	self._bRestoreMPAfterRound = kv.RestoreMPAfterRound or false

	self._bUseReactiveDifficulty = kv.UseReactiveDifficulty or false
    if testMode then
	  self._flPrepTimeBetweenRounds = 1
    else
      self._flPrepTimeBetweenRounds = tonumber( kv.PrepTimeBetweenRounds or 0 )
    end
	self._flItemExpireTime = tonumber( kv.ItemExpireTime or 10.0 )

	self:_ReadRandomSpawnsConfiguration( kv["RandomSpawns"] )
	self:_ReadLootItemDropsConfiguration( kv["ItemDrops"] )
	self:_ReadRoundConfigurations( kv )
end


-- Verify spawners if random is set
function CHoldoutGameMode:ChooseRandomSpawnInfo()
	if #self._vRandomSpawnsList == 0 then
		error( "Attempt to choose a random spawn, but no random spawns are specified in the data." )
		return nil
	end
	return self._vRandomSpawnsList[ RandomInt( 1, #self._vRandomSpawnsList ) ]
end


-- Verify valid spawns are defined and build a table with them from the keyvalues file
function CHoldoutGameMode:_ReadRandomSpawnsConfiguration( kvSpawns )
	self._vRandomSpawnsList = {}
	if type( kvSpawns ) ~= "table" then
		return
	end
	for _,sp in pairs( kvSpawns ) do 
		table.insert( self._vRandomSpawnsList, {
			szSpawnerName = sp.SpawnerName or "",
			szFirstWaypoint = sp.Waypoint or ""
		} )
	end
end



function CHoldoutGameMode:OnHeroLevelUp(keys)

  local player = PlayerInstanceFromIndex( keys.player )
  local hero = player:GetAssignedHero()
  local level = hero:GetLevel()
  -- 如果英雄的等级不是2的倍数，那么这个等级就不给技能点
  local _,l = math.modf((level-1)/2)
  if l ~= 0 then
    local p = hero:GetAbilityPoints()
    hero:SetAbilityPoints(p - 1)
  end
  local _playerId=hero:GetPlayerID()
  CustomGameEventManager:Send_ServerToPlayer(player,"UpdateAbilityList", {heroName=false,playerId=_playerId})
end

function CHoldoutGameMode:OnItemPurchased(keys) 
  --DeepPrint(keys)
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.PlayerID),"UpdatePlayerAbilityList", {playerId=keys.PlayerID})
end


function CHoldoutGameMode:ModifyGoldFilter(keys)    
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.player_id_const),"UpdatePlayerAbilityList", {playerId=keys.player_id_const})
  return true
end




-- If random drops are defined read in that data
function CHoldoutGameMode:_ReadLootItemDropsConfiguration( kvLootDrops )
	self._vLootItemDropsList = {}
	if type( kvLootDrops ) ~= "table" then
		return
	end
	for _,lootItem in pairs( kvLootDrops ) do
		table.insert( self._vLootItemDropsList, {
			szItemName = lootItem.Item or "",
			nChance = tonumber( lootItem.Chance or 0 )
		})
	end
end


-- Set number of rounds without requiring index in text file
function CHoldoutGameMode:_ReadRoundConfigurations( kv )
	self._vRounds = {}
	while true do
		local szRoundName = string.format("Round%d", #self._vRounds + 1 )    --#是取长度运算，表示往后再加一个位置
		local kvRoundData = kv[ szRoundName ]
		if kvRoundData == nil then
			return
		end
		local roundObj = CHoldoutGameRound()
		roundObj:ReadConfiguration( kvRoundData, self, #self._vRounds + 1 )
		table.insert( self._vRounds, roundObj )
	end
end


-- When game state changes set state in script
function CHoldoutGameMode:OnGameRulesStateChange()
	local nNewState = GameRules:State_Get()
	if nNewState ==  DOTA_GAMERULES_STATE_HERO_SELECTION then
		PrecacheUnitByNameAsync('npc_precache_always', function() end) 
		ShowGenericPopup( "#holdout_instructions_title", "#holdout_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	end
	if nNewState ==  DOTA_GAMERULES_STATE_GAME_IN_PROGRESS   then
		 CustomGameEventManager:Send_ServerToAllClients( "UpdateCmHud", {} )
		 self:SetDifficulty()
	end
end

-- Evaluate the state of the game 
function CHoldoutGameMode:OnThink()
	if GameRules:State_Get() > DOTA_GAMERULES_STATE_HERO_SELECTION then
	end
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		if self.startflag==0 then 
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
		self.startflag=1
	    end
		self:_CheckForDefeat()
		self:_ThinkLootExpiry()
		if self._flPrepTimeEnd ~= nil then
			self:_ThinkPrepTime()
		elseif self._currentRound ~= nil then
			self._currentRound:Think()
			if self._currentRound:IsFinished() then
				UTIL_ResetMessageTextAll()
                self:RoundEnd()
			end
		end
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then		-- Safe guard catching any state that may exist beyond DOTA_GAMERULES_STATE_POST_GAME
		return nil
	end
	return 1
end

function CHoldoutGameMode:_RefreshPlayers()
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero then
				  if not hero:IsAlive() then
				    	hero:RespawnUnit()
				  end
				  hero:SetHealth( hero:GetMaxHealth() )
				  hero:SetMana( hero:GetMaxMana() )
			    end
			end
		end
	end
end


function CHoldoutGameMode:_CheckForDefeat()
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return
	end

	local bAllPlayersDead = true
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if  PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero and hero:IsAlive() then
					bAllPlayersDead = false
					self.loseflag=0
				end
			end
		end
	end

	if bAllPlayersDead and self._currentRound~=nil then
		self.loseflag=self.loseflag+1
	end
	if self.loseflag>6 then
		self.last_live=self.last_live-1
		 if self.last_live==0 then
		  GameRules:MakeTeamLose( DOTA_TEAM_GOODGUYS )
		  return
	       elseif self.last_live==2 then
		     Notifications:BottomToAll({text = "#life_left_note_2", duration = 4, style = {color = "Fuchsia"}, continue = true})
		        if self._currentRound then
		          self._currentRound.achievement_flag=false
		    	  self._currentRound:End()
		        end
				self._currentRound = nil
				self:_RefreshPlayers()
				self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
		    elseif self.last_live==1 then
		    	 Notifications:BottomToAll({text = "#life_left_note_1", duration = 4, style = {color = "Fuchsia"}, continue = true})
		         if self._currentRound then
		          self._currentRound.achievement_flag=false
		    	  self._currentRound:End()
		         end
				 self._currentRound = nil
				 self:_RefreshPlayers()
				 self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
		  end
	end	
end




function CHoldoutGameMode:_ThinkPrepTime()
	if GameRules:GetGameTime() >= self._flPrepTimeEnd then
		self._flPrepTimeEnd = nil
		if self._entPrepTimeQuest then
			UTIL_Remove( self._entPrepTimeQuest )
			self._entPrepTimeQuest = nil
		end

		if self._nRoundNumber > #self._vRounds then
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
			return false
		end

		self._currentRound = self._vRounds[ self._nRoundNumber ]
		self._currentRound:Begin()
		return
	end

	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous( "quest", { name = "PrepTime", title = "#DOTA_Quest_Holdout_PrepTime" } )
		self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber )
		self._vRounds[ self._nRoundNumber ]:Precache()
	end
	self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime() )
end


function CHoldoutGameMode:_ThinkLootExpiry()
	if self._flItemExpireTime <= 0.0 then
		return
	end

	local flCutoffTime = GameRules:GetGameTime() - self._flItemExpireTime

	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		  local containedItem = item:GetContainedItem()	
		  if  containedItem then
		          if containedItem:GetAbilityName() == "item_bag_of_gold" or containedItem:GetAbilityName() == "item_rock" or item.Holdout_IsLootDrop then
		             self:_ProcessItemForLootExpiry( item, flCutoffTime )
		           end
		    else
		    self:_ProcessItemForLootExpiry( item, flCutoffTime )
		  end
	end
end


function CHoldoutGameMode:_ProcessItemForLootExpiry( item, flCutoffTime )
	if item:IsNull() then
		return false
	end
	if item:GetCreationTime() >= flCutoffTime then
		return true
	end

	local containedItem = item:GetContainedItem()
	if containedItem and containedItem:GetAbilityName() == "item_bag_of_gold" then
		if self._currentRound and self._currentRound.OnGoldBagExpired then
			self._currentRound:OnGoldBagExpired()
		end
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item )
	ParticleManager:SetParticleControl( nFXIndex, 0, item:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	local inventoryItem = item:GetContainedItem()
	if inventoryItem then
		UTIL_Remove( inventoryItem )
	end
	UTIL_Remove( item )
	return false
end



function CHoldoutGameMode:_SpawnHeroClientEffects( hero, nPlayerID )
	-- Spawn these effects on the client, since we don't need them to stay in sync or anything
	-- ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticleForPlayer( "particles/generic_gameplay/winter_effects_hero.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, PlayerResource:GetPlayer( nPlayerID ) ) )	-- Attaches the breath effects to players for winter maps
	ParticleManager:ReleaseParticleIndex( ParticleManager:CreateParticleForPlayer( "particles/frostivus_gameplay/frostivus_hero_light.vpcf", PATTACH_ABSORIGIN_FOLLOW, hero, PlayerResource:GetPlayer( nPlayerID ) ) )
end


function CHoldoutGameMode:OnNPCSpawned( event )

	local spawnedUnit = EntIndexToHScript( event.entindex )

	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
		return 
	end
 Timers:CreateTimer({
    endTime = 0.3, 
    callback = function()
      if  spawnedUnit:IsSummoned() and not spawnedUnit:IsRealHero()  then
		local playerid=spawnedUnit:GetOwner():GetPlayerID()
        print(spawnedUnit:GetUnitName().."has owner, ID"..playerid)
		local owner=spawnedUnit:GetOwner()
		local crownLevel=0
		if owner:HasModifier("modifier_crown_5_datadriven") then
			crownLevel=5
		else
			if owner:HasModifier("modifier_crown_4_datadriven") then
				crownLevel=4
			else
				if owner:HasModifier("modifier_crown_3_datadriven") then
					crownLevel =3
				else
					if owner:HasModifier("modifier_crown_2_datadriven") then
						crownLevel =2 
					else
						if owner:HasModifier("modifier_crown_1_datadriven") then
							crownLevel=1
						end
					end
				end
			end
		end

		if crownLevel>0 then
			spawnedUnit.owner=owner
			owner.crownLevel=crownLevel
			if  spawnedUnit:HasAbility("crown_summoned_buff") then

			else 
	            spawnedUnit:AddAbility("crown_summoned_buff")
			    local ability=spawnedUnit:FindAbilityByName("crown_summoned_buff")
			    ability:SetLevel(crownLevel)
            end
        else
        	if spawnedUnit:FindAbilityByName("crown_summoned_buff") then
				spawnedUnit:RemoveAbility("crown_summoned_buff")
			end
        end
    end

	-- Attach client side hero effects on spawning players
	if spawnedUnit:IsRealHero() then
		for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
			if ( PlayerResource:IsValidPlayer( nPlayerID ) ) then
				self:_SpawnHeroClientEffects( spawnedUnit, nPlayerID )
			end
		end
	end
	if spawnedUnit:GetTeam()==DOTA_TEAM_GOODGUYS and string.sub(spawnedUnit:GetUnitName(),1,14)~="npc_dota_tiny_"then
		if spawnedUnit:HasAbility("damage_counter") then
		else
			spawnedUnit:AddAbility("damage_counter")
			local ability=spawnedUnit:FindAbilityByName("damage_counter")
			ability:SetLevel(1)
			if self.map_difficulty==1 then
				ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_map_easy_show", {})
			end
			if self.map_difficulty==3 then
				ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_map_hard_show", {})
			end
		end
	end
	if spawnedUnit:GetTeam()==DOTA_TEAM_BADGUYS and self.map_difficulty==3  then
		if spawnedUnit:HasAbility("monster_buff_datadriven") then
		else
			spawnedUnit:AddAbility("monster_buff_datadriven")
		end
	end
    end
  })
	
end


--[[
function CHoldoutGameMode:OnNPCReplaced( event )
	local spawnedUnit = EntIndexToHScript( event.new_entindex )
	print("new npc"..spawnedUnit:GetUnitName())
end
]]
--[[
function CHoldoutGameMode:OnUseAbility(event)
	local abilityName=event.abilityname
	print(abilityName)
	if abilityToPlayer[abilityName]~=nil then
		abilityToPlayer[abilityName]=event.PlayerID
		print("PID"..abilityToPlayer[abilityName])
	end
end
]]

-- Attach client-side hero effects for a reconnecting player
function CHoldoutGameMode:OnPlayerReconnected( event )
	local nReconnectedPlayerID = event.PlayerID
	for _, hero in pairs( Entities:FindAllByClassname( "npc_dota_hero" ) ) do
		if hero:IsRealHero() then
			self:_SpawnHeroClientEffects( hero, nReconnectedPlayerID )
		end
	end
end


function CHoldoutGameMode:RoundEnd()
	local data = {}
	local playercount = self._currentRound.Palyer_Number
	for i=0,playercount-1 do
		local line={}
		line.playerid=i
		line.total_damage= self._currentRound._vPlayerStats[i].nTotalDamage
		line.total_heal=self._currentRound._vPlayerStats[i].nCreepsKilled
		line.gold_collect=self._currentRound._vPlayerStats[i].nGoldBagsCollected
		table.insert(data, line)
	end
	table.sort(data,function(a,b) return a.total_damage>b.total_damage end )       
	data.playercount=playercount
	data.timecost=GameRules:GetGameTime()-self._currentRound.Begin_Time

    self._currentRound:End()
	if self._currentRound.achievement_flag then
		data.acheivement_flag=1
	else
		data.acheivement_flag=0
	end
	CustomGameEventManager:Send_ServerToAllClients("game_end", data)

	self._currentRound = nil
	self:_RefreshPlayers()
	self._nRoundNumber = self._nRoundNumber + 1
	if self._nRoundNumber > #self._vRounds then
		self._nRoundNumber = 1
		GameRules:MakeTeamLose( DOTA_TEAM_BADGUYS )
	else
		self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	end
end



function CHoldoutGameMode:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )

    if killedUnit then
		 if killedUnit:GetUnitName()=="npc_dota_warlock_boss_2" and killedUnit.die_in_peace==nil then
           self:RoundEnd()
         end
         if killedUnit:GetUnitName()=="npc_dota_boss_enchantress" and self._currentRound._alias=="tree" and killedUnit.die_in_peace==nil  then
           self:RoundEnd()
         end
	end

	if killedUnit and killedUnit:IsRealHero() then
		if self._currentRound._alias=="skeleton"  and self._currentRound.achievement_flag then
		         local playername=PlayerResource:GetPlayerName(killedUnit:GetPlayerOwnerID())
                 local hero_name=PlayerResource:GetSelectedHeroName(killedUnit:GetPlayerOwnerID())  
                 Notifications:BottomToAll({hero = hero_name, duration = 4})
		         Notifications:BottomToAll({text = playername.." ", duration = 4, continue = true})
		         Notifications:BottomToAll({text = "#round1_acheivement_fail_note", duration = 4, style = {color = "Orange"}, continue = true})
		   self._currentRound.achievement_flag=false
		end	
		local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
		newItem:SetPurchaseTime( 0 )
		newItem:SetPurchaser( killedUnit )
		 if killedUnit:FindAbilityByName("skeleton_king_reincarnation") ~=nil then
		 	else
		 	killedUnit:SetTimeUntilRespawn(killedUnit:GetRespawnTime() + 999)
	     end
		local tombstone = SpawnEntityFromTableSynchronous( "dota_item_tombstone_drop", {} )
		tombstone:SetContainedItem( newItem )
		tombstone:SetAngles( 0, RandomFloat( 0, 360 ), 0 )
		FindClearSpaceForUnit( tombstone, killedUnit:GetAbsOrigin(), true )	
	end
end


function CHoldoutGameMode:CheckForLootItemDrop( killedUnit )
	for _,itemDropInfo in pairs( self._vLootItemDropsList ) do
		if RollPercentage( itemDropInfo.nChance ) then
			local newItem = CreateItem( itemDropInfo.szItemName, nil, nil )
			newItem:SetPurchaseTime( 0 )
			if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
				item:SetStacksWithOtherOwners( true )
			end
			local drop = CreateItemOnPositionSync( killedUnit:GetAbsOrigin(), newItem )
			drop.Holdout_IsLootDrop = true
		end
	end
end

function CHoldoutGameMode:OnItemPickUp( event ,level )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	if string.sub(event.itemname,1,20)== "item_treasure_chest_" then
		SpecialItemAdd( event,  tonumber(string.sub(event.itemname,21,21)))
		UTIL_Remove( item )
	end
end

-- Custom game specific console command "holdout_test_round"
function CHoldoutGameMode:_TestRoundConsoleCommand( cmdName, roundNumber, delay )
	local nRoundToTest = tonumber( roundNumber )
	print (string.format( "Testing round %d", nRoundToTest ) )
	if nRoundToTest <= 0 or nRoundToTest > #self._vRounds then
		Msg( string.format( "Cannot test invalid round %d", nRoundToTest ) )
		return
	end

	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if PlayerResource:IsValidPlayer( nPlayerID ) then
			PlayerResource:ModifyGold( nPlayerID, 999999, true, DOTA_ModifyGold_Unspecified )
			PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():SetAbilityPoints(50)
			PlayerResource:SetBuybackCooldownTime( nPlayerID, 0 )
			PlayerResource:SetBuybackGoldLimitTime( nPlayerID, 0 )
			PlayerResource:ResetBuybackCostTime( nPlayerID )
		end
	end
	if self._entPrepTimeQuest then
		UTIL_Remove( self._entPrepTimeQuest )
		self._entPrepTimeQuest = nil
	end
	if self._currentRound ~= nil then
		self._currentRound:End()
		self._currentRound = nil
	end
	for _,item in pairs( Entities:FindAllByClassname( "dota_item_drop")) do
		local containedItem = item:GetContainedItem()
		if containedItem then
			UTIL_Remove( containedItem )
		end
		UTIL_Remove( item )
	end
	self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
	self._nRoundNumber = nRoundToTest
	if delay ~= nil then
		self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber( delay )
	end
end


function CHoldoutGameMode:_StatusReportConsoleCommand( cmdName )
	print( "*** Holdout Status Report ***" )
	print( string.format( "Current Round: %d", self._nRoundNumber ) )
	if self._currentRound then
		self._currentRound:StatusReport()
	end
	print( "*** Holdout Status Report End *** ")
end


function CHoldoutGameMode:CreateNetTablesSettings()
    -- Hero pool
    for group, heroes in pairs( self.HeroesKV ) do
        CustomNetTables:SetTableValue( "heroes", group, heroes )
    end
    -- Abilities 
    for heroName, abilityKV in pairs( self.AbilitiesKV ) do
        CustomNetTables:SetTableValue( "abilities", heroName, abilityKV )
    end
    for abilityName, abilityCost in pairs(self.AbilitiesCostKV) do
        CustomNetTables:SetTableValue ("abilitiesCost", abilityName, {tonumber(abilityCost)})
    end
end