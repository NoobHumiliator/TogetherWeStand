--[[
	Underscore prefix such as "_function()" denotes a local function and is used to improve readability
	Variable Prefix Examples
		"fl"	Float
		"n"		Int
		"v"		Table
		"b"		Boolean
		"h"     Handle
		"s"     String
]]

if CHoldoutGameMode == nil then
	_G.CHoldoutGameMode = class({}) 	
end

testMode=false
--testMode=true --减少刷兵间隔，增加初始金钱



require( "holdout_game_round" )
require( "holdout_game_spawner" )
require( "util" )
require( "timers")
require( "spell_shop_UI")
require( "loot_controller" )
require( "difficulty_select_UI")
require( "global_setting")
require( "tws_util")
require( "libraries/notifications")
require( "item_ability/damage_filter")
require( "quest_system")
require( "vip/extra_particles")
require( "server/rank")
require( "server/detail")

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
	PrecacheItemByNameSync( "item_treasure_chest_1", context )
	PrecacheItemByNameSync( "item_treasure_chest_2", context )
	PrecacheItemByNameSync( "item_treasure_chest_3", context )
	PrecacheItemByNameSync( "item_treasure_chest_4", context )
	PrecacheItemByNameSync( "item_treasure_chest_5", context )
	PrecacheItemByNameSync( "item_treasure_chest_6", context )
	PrecacheItemByNameSync( "item_treasure_chest_7", context )
	PrecacheItemByNameSync( "item_treasure_chest_8", context )
	PrecacheUnitByNameAsync('npc_dota_tiny_1',function() end)
end



function CHoldoutGameMode:InitGameMode()

    GameRules:GetGameModeEntity().CHoldoutGameMode = self
    
	Timers:start()
	LootController:ReadConfigration() 
	self.startflag=0 
	self.loseflag=0 
	self.last_live=5
	self._nRoundNumber = 1
	self._currentRound = nil
	self._flLastThinkGameTime = nil
	self.enchantress_already_die_flag=0
	self:_ReadGameConfiguration()
	self.itemSpawnIndex = 1
	self.flProgressTime=0 --记录progress阶段开始时间
	self.flDDadjust=1  --保存难度产生的伤害系数修正
	self.flDHPadjust=1  --保存难度产生的血量系数修正
	self.nTrialSetTime=12
	GameRules:SetTimeOfDay( 0.75 )
	GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
	GameRules:SetHeroRespawnEnabled( false )
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 35.0 )
    

	if testMode then
	  GameRules:SetPreGameTime( 3.0 )
	  GameRules:SetGoldTickTime( 0.5 )
	  GameRules:SetGoldPerTick( 10000 )
	  self.nTrialSetTime=2
	  else
	  GameRules:SetPreGameTime( 15.0 )
	  GameRules:SetGoldTickTime( 60.0 )
	  GameRules:SetGoldPerTick( 0 )
    end
	GameRules:SetPostGameTime( 10.0 )
	GameRules:SetTreeRegrowTime( 35.0 )
	GameRules:SetHeroMinimapIconScale( 0.7 )
	GameRules:SetCreepMinimapIconScale( 0.7 )
	GameRules:SetRuneMinimapIconScale( 0.7 )
	GameRules:GetGameModeEntity():SetUseCustomHeroLevels( true )
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel( 999 )
	local xpTable = {}
	xpTable[0]=0
	xpTable[1]=200
	for i = 2, 1000 do
		xpTable[i] = xpTable[i-1]+i*100
	end
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel( xpTable )
	GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride( true )
	GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible( false )
	-- Custom console commands
	Convars:RegisterCommand( "test_round", function(...) return self:_TestRoundConsoleCommand( ... ) end, "Test a round of holdout.", FCVAR_CHEAT )
	Convars:RegisterCommand( "status_report", function(...) return self:_StatusReportConsoleCommand( ... ) end, "Report the status of the current holdout game.", FCVAR_CHEAT )
	Convars:RegisterCommand( "list_modifiers", function(...) return self:_ListModifiers( ... ) end, "List modifiers of all hero.", FCVAR_CHEAT )
    --UI交互
    CustomGameEventManager:RegisterListener("AddAbility", Dynamic_Wrap(CHoldoutGameMode, 'AddAbility'))
    CustomGameEventManager:RegisterListener("RemoveAbility", Dynamic_Wrap(CHoldoutGameMode, 'RemoveAbility'))
    CustomGameEventManager:RegisterListener("LevelUpAttribute", Dynamic_Wrap(CHoldoutGameMode, 'LevelUpAttribute'))
    CustomGameEventManager:RegisterListener("PointToGold", Dynamic_Wrap(CHoldoutGameMode, 'PointToGold'))


    CustomGameEventManager:RegisterListener("SelectDifficulty",Dynamic_Wrap(CHoldoutGameMode, 'SelectDifficulty'))
    CustomGameEventManager:RegisterListener("SendTrialLeveltoServer",Dynamic_Wrap(CHoldoutGameMode, 'SendTrialLeveltoServer'))
    

	-- Hook into game events allowing reload of functions at run time
	ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameMode, "OnNPCSpawned" ), self )
	--ListenToGameEvent( "npc_replaced", Dynamic_Wrap( CHoldoutGameMode, "OnNPCReplaced" ), self )
	--ListenToGameEvent( "dota_player_used_ability", Dynamic_Wrap( CHoldoutGameMode, "OnUseAbility" ), self )
	--ListenToGameEvent( "player_reconnected", Dynamic_Wrap( CHoldoutGameMode, 'OnPlayerReconnected' ), self )
	ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHoldoutGameMode, 'OnEntityKilled' ), self )
	ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( CHoldoutGameMode, "OnGameRulesStateChange" ), self )
	ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( CHoldoutGameMode, "OnItemPickUp"), self )
	ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap(CHoldoutGameMode, "OnHeroLevelUp"), self)
	ListenToGameEvent( "dota_item_purchased", Dynamic_Wrap(CHoldoutGameMode, "OnItemPurchased"), self)
	ListenToGameEvent( "dota_player_pick_hero", Dynamic_Wrap(CHoldoutGameMode, "OnPlayerPickHero"), self)

    --读取spell shop UI的kv内容
	self.HeroesKV = LoadKeyValues("scripts/kv/spell_shop_ui_herolist.txt")
    self.AbilitiesKV = LoadKeyValues("scripts/kv/spell_shop_ui_abilities.txt")
    self.AbilitiesCostKV = LoadKeyValues("scripts/kv/spell_shop_ui_abilities_cost.txt")
    
	GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(CHoldoutGameMode, "DamageFilter"), self)
	GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CHoldoutGameMode, "OrderFilter"), self)
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
	  self._flPrepTimeBetweenRounds = 2
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
  local _playerId=hero:GetPlayerID()
  if keys.level== level then
	if hero:HasAbility("arc_warden_tempest_double") then
		local ability= hero:FindAbilityByName("arc_warden_tempest_double")
		local octarine_adjust=1
		if hero:HasItemInInventory("item_octarine_core") then
		   octarine_adjust=0.75
		end
	    local cooldown=ability:GetCooldown(ability:GetLevel()-1)*octarine_adjust
		if  ability:GetCooldownTimeRemaining()>cooldown*0.9 then  --如果风暴双雄刚刚释放完毕 不扣除
			CustomGameEventManager:Send_ServerToPlayer(player,"UpdateAbilityList", {heroName=false,playerId=_playerId})
			return
		end
	end 
    if keys.level==17 or keys.level==19 or keys.level==21 or keys.level==22 or keys.level==23 or keys.level==24 then --7.0以后不给技能点
       local p = hero:GetAbilityPoints()
       hero:SetAbilityPoints(p+1)   --不给技能点的这几级 先加回来
    end
	-- 如果英雄的等级不是2的倍数，那么这个等级就不给技能点
	local _,l = math.modf((level-1)/2)
	if l ~= 0 then
	  local p = hero:GetAbilityPoints()
	  hero:SetAbilityPoints(p - 1)
	end
  end
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


function CHoldoutGameMode:OnPlayerPickHero(keys)
  local hero = EntIndexToHScript(keys.heroindex)
  print(hero:GetUnitName())
  if IsValidEntity(hero) then
  	for i=1,20 do
  		local ability=hero:GetAbilityByIndex(i-1)
  		if ability then
  			print("Abilities Report: "..hero:GetUnitName().."ability["..i.."] is "..ability:GetAbilityName())
  			if string.find(ability:GetAbilityName(),"tws_ability_empty_") then
  				hero:RemoveAbility(ability:GetAbilityName())
  			end
  		else
  			print("Abilities Report: "..hero:GetUnitName().."ability["..i.."] is empty")
  		end
  	end
  end
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
	if nNewState==DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		for i=1,5 do  
			Rank:GetRankDataFromServer(i) --从服务器获取天梯数据
		end
	end
	if nNewState ==  DOTA_GAMERULES_STATE_HERO_SELECTION then
		PrecacheUnitByNameAsync('npc_precache_always', function() end) 
		ShowGenericPopup( "#holdout_instructions_title", "#holdout_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN )
	end
	if nNewState ==  DOTA_GAMERULES_STATE_GAME_IN_PROGRESS   then
		 self.flProgressTime=GameRules:GetGameTime()
		 CustomGameEventManager:Send_ServerToAllClients( "UpdateCmHud", {} )
		 self:SetBaseDifficulty()
	end
end

-- Evaluate the state of the game 
function CHoldoutGameMode:OnThink()
	if GameRules:State_Get() > DOTA_GAMERULES_STATE_HERO_SELECTION then
	end
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then  
	   if self.map_difficulty==nil then  --难度未定，不能开始
          if  GameRules:GetGameTime()>self.flProgressTime + self.nTrialSetTime then
          	self:SetTrialMapDifficulty()
          end
	   else
	   	    self:AddHeroDifficultyModifier()
			if self.startflag==0 then 
			self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
			self.startflag=1
		    end
			self:_CheckForDefeat() --无影拳CD的特殊修正
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
				  --重置买活时间与惩罚
				  --PlayerResource:SetBuybackCooldownTime( nPlayerID, 0 )  
                  hero.heal_absorb=nil
			      PlayerResource:SetBuybackGoldLimitTime( nPlayerID, 0 )
			      PlayerResource:ResetBuybackCostTime( nPlayerID )
			      PlayerResource:SetCustomBuybackCooldown(nPlayerID,0)
                  hero:RemoveModifierByName("modifier_fire_twin_debuff")
                  hero:RemoveModifierByName("modifier_dark_twin_debuff")
                  hero:RemoveModifierByName("modifier_charge_dot")
                  hero:RemoveModifierByName("modifier_suffocating_bubble")
			      hero:RemoveModifierByName("modifier_overflow_show")
			      hero:RemoveModifierByName("modifier_silence_permenant")
			      hero:RemoveModifierByName("modifier_affixes_falling_rock")
			      hero:RemoveModifierByName("modifier_overflow_stack")
				  hero:SetHealth( hero:GetMaxHealth() )
				  hero:SetMana( hero:GetMaxMana() )
			    end
			end
		end
	end
end


function CHoldoutGameMode:_CheckForDefeat()  --无影拳CD的特殊修正
	if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		return
	end

	local bAllPlayersDead = true
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if  PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero and hero:IsAlive() then
					if hero:HasModifier("modifier_ember_spirit_sleight_of_fist_caster_invulnerability") then --无敌buff期间不走冷却
						local modifier=hero:FindModifierByName("modifier_ember_spirit_sleight_of_fist_caster_invulnerability")
						local ability=modifier:GetAbility()
						local octarine_adjust=1
						if hero:HasItemInInventory("item_octarine_core") then
						   octarine_adjust=0.75
						end
						ability:StartCooldown(ability:GetCooldown(ability:GetLevel()-1)*octarine_adjust)
					end
                    --local vModifier_table=hero:FindAllModifiers()
                    --for k,v in pairs(vModifier_table) do
                    	--print("Effect Name"..v:GetName().."")
                    --end
                    --PrintTable(vModifier_table,nil,nil)
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
		 table.insert(vFailedRound, self._nRoundNumber) --记录下折在第几关了
		 if self.last_live==0 then
		 	 if self._nRoundNumber > 2 and not GameRules:IsCheatMode() then  --如果通过了条件，记录细节
                 Detail:RecordDetail(self._nRoundNumber-1,self.map_difficulty) 
	         end
		 	 if self.map_difficulty==3 and not GameRules:IsCheatMode()then 
			   Rank:RecordGame(self._nRoundNumber-1,DOTA_TEAM_GOODGUYS) --储存并结束游戏
			   return
			 else
               GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
			   return
			 end
	     elseif self.last_live<0 then
	         return
	     else
	       	 Notifications:BottomToAll( {text="#round_fail", duration=3, style={color="Fuchsia"}})
             Notifications:BottomToAll( {text=tostring(self.last_live), duration=3, style={color="Red"}, continue=true})
             Notifications:BottomToAll( {text="#chance_left", duration=3, style={color="Fuchsia"}, continue=true})
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
		--[[ 绿字任务
		if self._entPrepTimeQuest then
			UTIL_Remove( self._entPrepTimeQuest )
			self._entPrepTimeQuest = nil
		end
        ]]
        if self._precacheFlag then
        	QuestSystem:DelQuest("PrepTime")
           self._precacheFlag=nil  --预载入标识
        end
		if self._nRoundNumber > #self._vRounds then
			 if self.map_difficulty==3 and not GameRules:IsCheatMode()then 
			   Rank:RecordGame(self._nRoundNumber-1,DOTA_TEAM_BADGUYS) --储存游戏成绩
			   return false
			 else
               GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
			   return false
			 end
		end

		self._currentRound = self._vRounds[ self._nRoundNumber ]
		self._currentRound:Begin()
		return
	end

	if not self._precacheFlag then
		QuestSystem:CreateQuest("PrepTime","#tws_quest_prep_time",self._flPrepTimeBetweenRounds,self._flPrepTimeBetweenRounds,nil,self._nRoundNumber)
	    self._vRounds[ self._nRoundNumber ]:Precache()	
        self._precacheFlag=true
	end
    QuestSystem:RefreshQuest("PrepTime", math.ceil(self._flPrepTimeBetweenRounds-self._flPrepTimeEnd+GameRules:GetGameTime()),self._flPrepTimeBetweenRounds,self._nRoundNumber)

    --[[ 绿字任务不再支持
	if not self._entPrepTimeQuest then
		self._entPrepTimeQuest = SpawnEntityFromTableSynchronous( "quest", { name = "PrepTime", title = "#DOTA_Quest_Holdout_PrepTime" } )
		self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_ROUND, self._nRoundNumber )
		self._vRounds[ self._nRoundNumber ]:Precache()
	end
	self._entPrepTimeQuest:SetTextReplaceValue( QUEST_TEXT_REPLACE_VALUE_CURRENT_VALUE, self._flPrepTimeEnd - GameRules:GetGameTime() )
	]]

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
		--print("Removing item "..inventoryItem:GetName()) 
		--有时候移除特殊物品会导致游戏崩溃（各类飞鞋）
		UTIL_Remove( inventoryItem )
	end
	UTIL_Remove( item )
	return false
end



function CHoldoutGameMode:OnNPCSpawned( event )

	local spawnedUnit = EntIndexToHScript( event.entindex )

	if not spawnedUnit or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
		return 
	end
	Timers:CreateTimer({
		endTime = 0.3, 
		callback = function()
		if  spawnedUnit~=nil and not spawnedUnit:IsNull() then
			if  spawnedUnit:IsSummoned() and not spawnedUnit:IsRealHero()  then
				local playerid=spawnedUnit:GetOwner():GetPlayerID()
             --print(spawnedUnit:GetUnitName().."has owner, ID"..playerid)
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

	-- Attach client side hero effects on spawning players 配置Vip的粒子效果
	if spawnedUnit:IsRealHero() then
		local hPlayerHero = spawnedUnit
		local nPlayerID= hPlayerHero:GetPlayerID()
				local nSteamID = PlayerResource:GetSteamAccountID(nPlayerID)    --获取steam ID 
			    if TableFindKey(vipSteamIDTable, nSteamID) then                       --steam ID 符合VIP表
			    	CreateVipParticle(hPlayerHero)
			    end
			end
			if spawnedUnit:GetTeam()==DOTA_TEAM_GOODGUYS and string.sub(spawnedUnit:GetUnitName(),1,14)~="npc_dota_tiny_"then
				if spawnedUnit:HasAbility("damage_counter") then
				else
					spawnedUnit:AddAbility("damage_counter")  --伤害计数器
					local ability=spawnedUnit:FindAbilityByName("damage_counter")
					ability:SetLevel(1)
                    spawnedUnit:AddAbility("attribute_bonus_datadriven")  --属性附加                
					if self.map_difficulty and self.map_difficulty==1 then
						ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_map_easy_show", {})
					end
					if self.map_difficulty and self.map_difficulty==3 then
						ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_map_hard_show", {})
					end
					if self.map_difficulty and self.map_difficulty>3 then
						ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_map_endless_stack", {})
						spawnedUnit:SetModifierStackCount("modifier_map_endless_stack",ability, self.map_difficulty-3)			
					end
				end
			end
			if spawnedUnit:GetTeam()==DOTA_TEAM_BADGUYS then
                if not spawnedUnit:HasAbility("monster_endless_stack_show") then
					spawnedUnit:AddAbility("monster_endless_stack_show")
				end
				local ability=spawnedUnit:FindAbilityByName("monster_endless_stack_show")
                local maxHealth=spawnedUnit:GetMaxHealth()
				local minDamage=spawnedUnit:GetBaseDamageMin()*self.flDDadjust
                local maxDamage=spawnedUnit:GetBaseDamageMax()*self.flDDadjust
                spawnedUnit.damageMultiple=self.flDDadjust
                spawnedUnit:SetBaseDamageMin(minDamage)
                spawnedUnit:SetBaseDamageMax(maxDamage)
                local newMaxHealth=maxHealth*self.flDHPadjust
             
                local healthRegen=math.max(newMaxHealth*0.0025, spawnedUnit:GetBaseHealthRegen())  --2.5%%的基础恢复

                if newMaxHealth<1 then --避免出现0血单位
                	newMaxHealth=1
                end
                spawnedUnit:SetBaseHealthRegen(healthRegen)
				spawnedUnit:SetBaseMaxHealth(newMaxHealth)
                spawnedUnit:SetMaxHealth(newMaxHealth)
                spawnedUnit:SetHealth(newMaxHealth)
                if self.map_difficulty==1 then
					ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_monster_debuff", {})
				end
				if self.map_difficulty==3 then
                    ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_monster_buff", {})
				end
                if self.map_difficulty>3 then
					ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_monster_map_endless_stack", {})
					spawnedUnit:SetModifierStackCount("modifier_monster_map_endless_stack",ability, self.map_difficulty-3)			
				end
                if self._currentRound~=nil and self._currentRound.vAffixes.necrotic then
                    spawnedUnit:AddAbility("affixes_ability_necrotic")
                    spawnedUnit:FindAbilityByName("affixes_ability_necrotic"):SetLevel(1)
                end
                if self._currentRound~=nil and self._currentRound.vAffixes.raging then
                    spawnedUnit:AddAbility("affixes_ability_raging")
                    spawnedUnit:FindAbilityByName("affixes_ability_raging"):SetLevel(1) 
                end
                if self._currentRound~=nil and self._currentRound.vAffixes.fortify then
                    spawnedUnit:AddAbility("affixes_ability_fortify")
                    spawnedUnit:FindAbilityByName("affixes_ability_fortify"):SetLevel(1) 
                end
                if self._currentRound~=nil and self._currentRound.vAffixes.bolstering then
                    spawnedUnit:AddAbility("affixes_ability_bolstering")
                    spawnedUnit:FindAbilityByName("affixes_ability_bolstering"):SetLevel(1)
                end
                if self._currentRound~=nil and self._currentRound.vAffixes.sanguine then
                    spawnedUnit:AddAbility("affixes_ability_sanguine")
                    spawnedUnit:FindAbilityByName("affixes_ability_sanguine"):SetLevel(1)
                end
                if self._currentRound~=nil and self._currentRound.vAffixes.spike then
                	spawnedUnit:AddAbility("affixes_ability_spike")
                    spawnedUnit:FindAbilityByName("affixes_ability_spike"):SetLevel(1)               
                end
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



function CHoldoutGameMode:RoundEnd()
	local data = {}
	local playercount = self._currentRound.Palyer_Number
	for i=0,playercount-1 do
		local line={}
		line.playerid=i
		line.total_damage= self._currentRound._vPlayerStats[i].nTotalDamage
		line.total_heal=self._currentRound._vPlayerStats[i].nTotalHeal
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
        if self._nRoundNumber > 2 and not GameRules:IsCheatMode() then  --如果通过了条件，记录细节
           Detail:RecordDetail(self._nRoundNumber-1,self.map_difficulty) 
	    end
		if self.map_difficulty==3 and not GameRules:IsCheatMode()then 
		   Rank:RecordGame(self._nRoundNumber-1,DOTA_TEAM_BADGUYS) --储存游戏	  
		   return false
		 else
		   GameRules:MakeTeamLose( DOTA_TEAM_BADGUYS ) --作弊或者难度不对，直接结束比赛
		   return false
		end
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
		killedUnit.heal_absorb=nil
		killedUnit:RemoveModifierByName("modifier_overflow_stack") --死亡移除溢出效果
		if self._currentRound  and  self._currentRound._alias=="skeleton"  and self._currentRound.achievement_flag then
		     local playername=PlayerResource:GetPlayerName(killedUnit:GetPlayerOwnerID())
		     local hero_name=PlayerResource:GetSelectedHeroName(killedUnit:GetPlayerOwnerID())  
		     Notifications:BottomToAll({hero = hero_name, duration = 4})
		     Notifications:BottomToAll({text = playername.." ", duration = 4, continue = true})
		     Notifications:BottomToAll({text = "#round1_acheivement_fail_note", duration = 4, style = {color = "Orange"}, continue = true})
		     QuestSystem:RefreshAchQuest("Achievement",0,1)
		     self._currentRound.achievement_flag=false
		end	
		local newItem = CreateItem( "item_tombstone", killedUnit, killedUnit )
		newItem:SetPurchaseTime( 0 )
		newItem:SetPurchaser( killedUnit )
		local reincarnation= killedUnit:FindAbilityByName("skeleton_king_reincarnation")
		if reincarnation ~=nil then --如果有重生技能 并且有蓝CD
            GameRules:SetHeroRespawnEnabled( true )
            Timers:CreateTimer(4,function()
				GameRules:SetHeroRespawnEnabled( false )
			end)
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
	if event.HeroEntityIndex then
	   local owner = EntIndexToHScript( event.HeroEntityIndex )
	   if string.sub(event.itemname,1,20)== "item_treasure_chest_" then
		  LootController:SpecialItemAdd(event, tonumber(string.sub(event.itemname,21,string.len(event.itemname))), #self._vRounds )
		  UTIL_Remove(item)
	   end
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
	self:_RefreshPlayers()
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



-- Custom game specific console command "list_modifiers"
function CHoldoutGameMode:_ListModifiers(cmdName)
	for nPlayerID = 0, DOTA_MAX_PLAYERS-1 do
		if PlayerResource:IsValidPlayer( nPlayerID ) then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero then
				  if hero:IsAlive() then
				     ListModifiers(hero)			    
				  end
				end
	        end 	
		end
	end
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