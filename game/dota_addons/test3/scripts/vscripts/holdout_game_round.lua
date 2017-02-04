--[[
	CHoldoutGameRound - A single round of Holdout
]]

require( "environment_controller/round_environment_controller")





if CHoldoutGameRound == nil then
	CHoldoutGameRound = class({})
end


function CHoldoutGameRound:ReadConfiguration( kv, gameMode, roundNumber )
	self._gameMode = gameMode
	self._nRoundNumber = roundNumber
	self._szRoundQuestTitle = kv.round_quest_title --round_quest_title 如果kv里面了没填就是nil
	self._szRoundTitle = kv.round_title or string.format( "Round%d", roundNumber )
	self._nBonusLevel = tonumber(kv.bonus_level) or roundNumber
	self._alias=kv.alias or string.format( "Round%d", roundNumber )   --设置一个别名，方便成就系统
    self._not_multiple=true
	self._nMaxGold = tonumber( kv.MaxGold or 0 )
	self._nBagCount = tonumber( kv.BagCount or 0 )
	self._nBagVariance = tonumber( kv.BagVariance or 0 )
	self._nFixedXP = tonumber( kv.FixedXP or 0 )
	self._nItemDropNum = tonumber( kv.ItemDropNum or 6 )  --单人玩家一关默认掉落6件物品 ，5人18件
 	self._vSpawners = {}
	self._totalCreatureNum=0
	self._environmentcontroller= EnvironmentController()
	self._environmentcontroller:Init()  --环境控制器初始化
	for k, v in pairs( kv ) do
		if type( v ) == "table" and v.NPCName then
			local spawner = CHoldoutGameSpawner()
			spawner:ReadConfiguration( k, v, self )
			self._vSpawners[ k ] = spawner
			if (v.TotalUnitsToSpawn) then   --统计怪物数量，影响物品爆率
              self._totalCreatureNum=self._totalCreatureNum+tonumber(v.TotalUnitsToSpawn)
			end
		end
	end
	for _, spawner in pairs( self._vSpawners ) do
		spawner:PostLoad( self._vSpawners )
	end
end


function CHoldoutGameRound:Precache()
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Precache()
	end
end

function CHoldoutGameRound:Begin()
	self._vEnemiesRemaining = {}
	self._vEventHandles = {
		ListenToGameEvent( "npc_spawned", Dynamic_Wrap( CHoldoutGameRound, "OnNPCSpawned" ), self ),
		ListenToGameEvent( "entity_killed", Dynamic_Wrap( CHoldoutGameRound, "OnEntityKilled" ), self ),
		ListenToGameEvent( "dota_item_picked_up", Dynamic_Wrap( CHoldoutGameRound, 'OnItemPickedUp' ), self ),
		ListenToGameEvent( "dota_holdout_revive_complete", Dynamic_Wrap( CHoldoutGameRound, 'OnHoldoutReviveComplete' ), self )
	}
	self.Begin_Time=GameRules:GetGameTime()
    --self:InitialAcheivementSystem()  --初始化成就系统
	self._vPlayerStats = {}
	self.Palyer_Number=0;
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		self._vPlayerStats[ nPlayerID ] = {
			nCreepsKilled = 0,
			nTotalDamage = 0,
			nTotalHeal=0,
			nGoldBagsCollected = 0,
			nPriorRoundDeaths = PlayerResource:GetDeaths( nPlayerID ),
			nPlayersResurrected = 0
		}
	end
    --调节人数奖励
    local playernumberbonus=0.5
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if  PlayerResource:HasSelectedHero( nPlayerID ) then
				playernumberbonus=playernumberbonus+0.5
				self.Palyer_Number=self.Palyer_Number+1
			end
		end
	end
	if self._not_multiple then
	  self._nFixedXP=self._nFixedXP*playernumberbonus
	  self._nMaxGold=self._nMaxGold*playernumberbonus
	  self._nGoldRemainingInRound = self._nMaxGold
	  self._nItemDropNum=self._nItemDropNum*playernumberbonus
	  self._nItemDropNum=math.ceil(self._nItemDropNum* hardLevelItemDropBonus[self._gameMode.map_difficulty])
	  self._not_multiple=false
    end

	self._nGoldBagsRemaining = self._nBagCount
	self._nGoldBagsExpired = 0
	self._nCoreUnitsTotal = 0
	LootController:SetItemProbability(self._nRoundNumber,self._gameMode.map_difficulty)
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Begin()
		self._nCoreUnitsTotal = self._nCoreUnitsTotal + spawner:GetTotalUnitsToSpawn()
	end
	self._nCoreUnitsKilled = 0
 
   local vAffixes_Text={
	    necrotic="#affixes_necrotic",
        teeming="#affixes_teeming",
        raging="#affixes_raging",
        fortify="#affixes_fortify",
        bolstering="#affixes_bolstering",
        overflowing="#affixes_overflowing",
        sanguine="#affixes_sanguine",
        silence="#affixes_silence",
        falling_rock="#affixes_falling_rock",
        spike="#affixes_spike"
    }
    local vAffixesTooltipAbility={
      necrotic="affixes_ability_necrotic",
      teeming="affixes_ability_tooltip_teeming",
      raging="affixes_ability_raging",
      fortify="affixes_ability_fortify",
      bolstering="affixes_ability_bolstering",
      overflowing="affixes_ability_tooltip_overflowing",
      sanguine="affixes_ability_sanguine",
      silence="affixes_ability_tooltip_silence",
      falling_rock="affixes_ability_tooltip_falling_rock",
      spike="affixes_ability_spike"
    }
    local affixesTooltipAbilityList={}
    self.bAffixFlag=false   --是否初始化过词缀
    self.vAffixes=
    {
        necrotic=false,
        teeming=false,
        raging=false,
        fortify=false,
        bolstering=false,
        overflowing=false,
        sanguine=false,
        silence=false,
        falling_rock=false,
        spike=false
    }
    local affixes_temp={}
    local affixes_number=0;
    if self._gameMode.map_difficulty<8 then  --五层以下试炼没有词缀 
       local affixes_number=math.floor( Quadric(2.5,-2.5,8-self._gameMode.map_difficulty) ) --2.5*n(n-1)+5=level  n为词缀数目
    end
    print("Affixes Number:"..affixes_number)
    for k,v in pairs(self.vAffixes) do
        table.insert(affixes_temp, k)
    end
	for i=1,affixes_number do
		if #affixes_temp>0 then
		  local random=RandomInt(1,#affixes_temp)
		  self.vAffixes[affixes_temp[random]]=true
		  table.remove(affixes_temp,random)
		end
	end
    --处理词缀Debuff
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero then
					ability=hero:FindAbilityByName("damage_counter")
					if ability then
						if self.vAffixes.overflowing then
						  ability:ApplyDataDrivenModifier(hero, hero, "modifier_overflow_show", {})
						end
                        if self.vAffixes.silence then
						  ability:ApplyDataDrivenModifier(hero, hero, "modifier_silence_permenant", {})
						end
			            if self.vAffixes.falling_rock then
						  ability:ApplyDataDrivenModifier(hero, hero, "modifier_affixes_falling_rock", {})
						end
					end
				end
			end
		end
	end	
   for k,v in pairs(self.vAffixes) do
   	  if v then
   	  	 print(vAffixes_Text[k])
   	  	 table.insert(affixesTooltipAbilityList, vAffixesTooltipAbility[k])
   	  	 Notifications:BottomToAll({text=vAffixes_Text[k], duration=10, style = {color = "Red"},continue=true})
   	  end
   end  
   QuestSystem:CreateQuest("Progress","#tws_quest_progress_text",0,self._nCoreUnitsTotal,nil,self._nRoundNumber)
   if self._szRoundQuestTitle ~=nil then
   	   local bonusItemName ="";
       local bonusLevel=self._nRoundNumber
       if bonusLevel>#bonusItems then  --如果关卡数超过定义的数组 调整一下
       	  bonusLevel=#bonusItems
       end

   	   if #bonusItems[bonusLevel] ==1 then
   	   	  bonusItemName=bonusItems[bonusLevel][1]
   	   else
   	   	  bonusItemName="item_treasure_chest_"..bonusLevel
   	   end
       QuestSystem:CreateAchQuest("Achievement",self._szRoundQuestTitle,1,1,nil,bonusItemName)
   end
   self:InitialAcheivementSystem()  --初始化成就系统
   if #affixesTooltipAbilityList>0 then
   	  QuestSystem:CreatAffixesQuest("Affixes",affixesTooltipAbilityList)
      self.bAffixFlag=true
   end
	local messageinfo = {
           message = self._szRoundTitle,
           duration=6
            }
     FireGameEvent("show_center_message",messageinfo)  
end


function CHoldoutGameRound:End()  
	for _, eID in pairs( self._vEventHandles ) do
		StopListeningToGameEvent( eID )
	end
	self._vEventHandles = {}

	for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
		if unit:IsAlive() then 
			if unit:GetUnitName()==("npc_dota_boss_rattletrap") then
				unit:RemoveAbility("rattletrap_gold_bag_fountain")
			end
			if unit:GetUnitName()==("npc_dota_boss_blue_dragon") then
				unit:RemoveAbility("blue_dragon_gold_bag_fountain")
			end
			if unit:GetUnitName()==("npc_dota_boss_mag") then
				unit:RemoveAbility("mag_gold_bag_fountain")
			end
			if unit:GetUnitName()==("npc_dota_boss_sky") then
				unit:RemoveAbility("sky_gold_bag_fountain")
			end
			if unit:GetUnitName()==("npc_dota_boss_enchantress") then
				unit.die_in_peace=true
				unit:RemoveAbility("enchantress_gold_bag_fountain")
			end
			if unit:GetUnitName()==("npc_dota_warlock_boss_2") then
				unit.die_in_peace=true
				unit:RemoveAbility("warlock_gold_bag_fountain")
			end
			if unit:GetUnitName()==("npc_dota_warlock_boss_2") then
				unit:RemoveAbility("warlock_gold_bag_fountain")
			end
			if unit:GetUnitName()==("npc_dota_splitter_b") then
				unit:RemoveAbility("creature_split_b")
			end
			if unit:GetUnitName()==("npc_dota_splitter_a") then
				unit:RemoveAbility("creature_split_a")
			end                    
			unit:ForceKill(true)
		end
	end


    for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
		if unit:IsAlive() then                   
		  unit:ForceKill(true)
		end
	end  


	if self._alias=="tiny" then
		KillTiny()  --小小关杀掉小小
	end

	for _,spawner in pairs( self._vSpawners ) do
		spawner:End()
	end
    
    if self._alias=="morphing" or self._alias=="morphing_again" then   --清理马甲单位
    	for _,unit in pairs( FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false )) do
			if unit:IsAlive() then 
				unit:ForceKill(true)
			end
	    end 
    end
    --删除本轮的UI 
	QuestSystem:DelQuest("Progress")
    if self._szRoundQuestTitle ~=nil then
       QuestSystem:DelQuest("Achievement")
    end
    if self.bAffixFlag then
       QuestSystem:DelAffixQuest()
    end
	self:CheckAchievement()
end


function CHoldoutGameRound:CheckAchievement()
     
    if self._szRoundQuestTitle and self.achievement_flag then      
        self:Special_Reward(self._nBonusLevel)
    end
    
end


function CHoldoutGameRound:InitialAcheivementSystem()   --初始化成就系统，设置监听，处理一些预载入等问题杂项
	self.achievement_flag=true 

	if self._alias=="skeleton" then
		if alreadyCached["npc_dota_hero_necrolyte"]==true then
		else
			PrecacheUnitByNameAsync('npc_precache_npc_dota_hero_necrolyte', function() end)
			alreadyCached["npc_dota_hero_necrolyte"]=true
		end
	end
	if self._alias=="bloodseeker" then
		Timers:CreateTimer({
			endTime = 1,
			callback = function()
			for playerid = 0 ,9 do 
				if PlayerResource:GetPlayer(playerid) ~= nil then 
					if PlayerResource:GetPlayer(playerid):GetAssignedHero():IsSilenced() and not PlayerResource:GetPlayer(playerid):GetAssignedHero():HasModifier("modifier_rattletrap_hookshot") and not PlayerResource:GetPlayer(playerid):GetAssignedHero():HasModifier("modifier_legion_commander_duel") then
						local playername=PlayerResource:GetPlayerName(playerid)
						local hero_name=PlayerResource:GetPlayer(playerid):GetAssignedHero():GetName()                    
						Notifications:BottomToAll({hero = hero_name, duration = 4})
						Notifications:BottomToAll({text = playername.." ", duration = 4, continue = true})
						Notifications:BottomToAll({text = "#round4_acheivement_fail_note", duration = 4, style = {color = "Orange"}, continue = true})                       
                        QuestSystem:RefreshAchQuest("Achievement",0,1)
						CHoldoutGameMode._currentRound.achievement_flag=false
						return nil
					end
				end
			end
			if CHoldoutGameMode._currentRound._alias=="satyr" then
				return nil
			else
				return 1
			end
		end
		})    
	end
	if self._alias=="satyr" then
		Timers:CreateTimer({
			endTime = 1,
			callback = function()
			for playerid = 0 ,9 do 
				if PlayerResource:GetPlayer(playerid) ~= nil then 
					if PlayerResource:GetPlayer(playerid):GetAssignedHero():IsStunned() then
						local playername=PlayerResource:GetPlayerName(playerid)
						local hero_name=PlayerResource:GetPlayer(playerid):GetAssignedHero():GetName()                    
						Notifications:BottomToAll({hero = hero_name, duration = 4})
						Notifications:BottomToAll({text = playername.." ", duration = 4, continue = true})
						Notifications:BottomToAll({text = "#round5_acheivement_fail_note", duration = 4, style = {color = "Orange"}, continue = true})
						QuestSystem:RefreshAchQuest("Achievement",0,1)
						CHoldoutGameMode._currentRound.achievement_flag=false
						return nil
					end
				end
			end
			if CHoldoutGameMode._currentRound._alias=="morphing" then
				return nil
			else
				return 1
			end
		end
		})    
	end
	if self._alias=="morphing" then
		GameRules:GetGameModeEntity():SetFogOfWarDisabled( true )
		GameRules:SendCustomMessage("#waterblowfog", 0, 0)
		QuestSystem:RefreshAchQuest("Achievement",0,5)
		self.achievement_flag=false
		local maxReaperNumber=0
		Timers:CreateTimer({
			endTime = 1,
			callback = function()
			local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
			local noobnumber=0
			local reapernumber=0
			if #targets > 0 then
				for i,unit in pairs(targets) do                                          
					if unit:GetUnitName()==("npc_dota_water_3") then     
						reapernumber=reapernumber+1
					end  
				end
			end
			if reapernumber>maxReaperNumber and reapernumber<6  then
				print("maxReaperNumber"..maxReaperNumber)
				maxReaperNumber=reapernumber
				QuestSystem:RefreshAchQuest("Achievement",maxReaperNumber,5)
			end
			if reapernumber>=5 then 
				Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="#round6_acheivement_fail_note", duration=4, style = {color = "Chartreuse"}})
				CHoldoutGameMode._currentRound.achievement_flag=true
				return nil
			end       	 
			if CHoldoutGameMode._currentRound._alias=="rattletrap" then
			       return nil
			   else
			   	return 0.4
			   end
			end
			})    
	end
	if self._alias=="rattletrap" then
		GameRules:GetGameModeEntity():SetFogOfWarDisabled( false )
		PrecacheUnitByNameAsync('npc_maze_wall', function() end)
		PrecacheUnitByNameAsync('bomber_bomb', function() end)
		PrecacheUnitByNameAsync('stasis_trap', function() end)
		PrecacheUnitByNameAsync('stasis_trap_precache',function()  end)
	end	
	if self._alias=="tiny" then
		self.achievement_flag=false
		if alreadyCached["npc_dota_hero_razor"]==true then
		else
			PrecacheUnitByNameAsync('npc_precache_npc_dota_hero_razor', function() end)
			alreadyCached["npc_dota_hero_razor"]=true
		end       
		PrecacheUnitByNameAsync('npc_dota_tiny_2',function() end)
        PrecacheUnitByNameAsync('npc_dota_tiny_3',function() end)
        PrecacheUnitByNameAsync('npc_dota_tiny_4',function() end)
        PrecacheUnitByNameAsync('npc_dota_tiny_5',function() end)
		GameRules:GetGameModeEntity():SetFogOfWarDisabled( false )
		local  wp = Entities:FindByName( nil, "waypoint_tiny1" )
		local entUnit = CreateUnitByName( "npc_dota_tiny_1", wp:GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
		GameRules:SendCustomMessage("#tinycapture_dbm", 0, 0)
	end	
	if self._alias=="mammoth"  then
		QuestSystem:RefreshAchQuest("Achievement",1,1)
	end
	if self._alias=="blue_dragon"  then
		QuestSystem:RefreshAchQuest("Achievement",1,1)
	end
	if self._alias=="tree"  then
		self.treeElderDieNumber=0
		QuestSystem:RefreshAchQuest("Achievement",0,10)
		self.achievement_flag=false
	end
	if self._alias=="morphing_again" then
		QuestSystem:RefreshAchQuest("Achievement",0,20)
		self.achievement_flag=false
		Timers:CreateTimer({
			endTime = 1,
			callback = function()
			local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
			local noobnumber=0
			local reapernumber=0
			if #targets > 0 then
				for i,unit in pairs(targets) do                                          
					if unit:GetUnitName()==("npc_dota_water_3") then     
						reapernumber=reapernumber+1
					end  
				end
			end			 
			if reapernumber>=20 then 
				Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="#round12_acheivement_fail_note", duration=4, style = {color = "Chartreuse"}})
				CHoldoutGameMode._currentRound.achievement_flag=true
				return nil
			end       	 
			if CHoldoutGameMode._currentRound._alias=="boss_party" then
			       return nil
			   else
			   	return 0.4
			   end
			end
			})    
	end
    if self._alias=="darkness"  then
		self._environmentcontroller:ApplyBlindModifier()
		self._environmentcontroller:SpawnLightBall()
	end
    if self._alias=="tusk" then
		if alreadyCached["npc_dota_hero_tusk"]==true then
		else
			PrecacheUnitByNameAsync('npc_dota_hero_tusk', function() end)
			alreadyCached["npc_dota_hero_tusk"]=true
		end
	end
end



function CHoldoutGameRound:Special_Reward(round_number)
    Timers:CreateTimer(4.0, function()
        local middle_dummy=Entities:FindByName( nil, "dummy_middle" )               
        local particle= ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf",PATTACH_ABSORIGIN_FOLLOW,middle_dummy)
        ParticleManager:ReleaseParticleIndex(particle)
        local spawnPoint = middle_dummy:GetAbsOrigin()
        local newItem = CreateItem( "item_treasure_chest_"..round_number, nil, nil )
        local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
        newItem:LaunchLootInitialHeight( false, 0, 200, 0.25, spawnPoint )
        EmitGlobalSound("Hero_LegionCommander.Duel.Victory")
     end)
end


function CHoldoutGameRound:Think()
	for _, spawner in pairs( self._vSpawners ) do
		spawner:Think()
	end
end


function CHoldoutGameRound:ChooseRandomSpawnInfo()
	return self._gameMode:ChooseRandomSpawnInfo()
end


function CHoldoutGameRound:IsFinished()
	for _, spawner in pairs( self._vSpawners ) do
		if not spawner:IsFinishedSpawning() then
			return false
		end
	end

	local nEnemiesRemaining = #self._vEnemiesRemaining
	if nEnemiesRemaining == 0 then
		return true
	end

    --print("unit number is"..nEnemiesRemaining)
    --DeepPrint(self._vEnemiesRemaining)
   

	if not self._lastEnemiesRemaining == nEnemiesRemaining then
		self._lastEnemiesRemaining = nEnemiesRemaining
		print ( string.format( "%d enemies remaining in the round...", #self._vEnemiesRemaining ) )
	end
	return false
end


-- Rather than use the xp granting from the units keyvalues file,
-- we let the round determine the xp per unit to grant as a flat value.
-- This is done to make tuning of rounds easier.
function CHoldoutGameRound:GetXPPerCoreUnit()
	if self._nCoreUnitsTotal == 0 then
		return 0
	else
		return math.floor( self._nFixedXP/ self._nCoreUnitsTotal )
	end
end


function CHoldoutGameRound:GetBasicBountyPerCoreUnit()
	if self._nCoreUnitsTotal == 0 then
		return 0
	else
		return math.floor( self._nMaxGold *0.25 / self._nCoreUnitsTotal ) --金币的1/4作为怪的基础金币奖励
	end
end


function CHoldoutGameRound:OnNPCSpawned( event )
	local spawnedUnit = EntIndexToHScript( event.entindex )
	if not spawnedUnit or spawnedUnit:IsPhantom() or spawnedUnit:GetUnitName()=="npc_majia_water_1" or spawnedUnit:GetUnitName()=="npc_dummy_blank" or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:GetUnitName() == "" or spawnedUnit:IsSummoned() then
		return
	end

	if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
		spawnedUnit:SetMustReachEachGoalEntity(true)
	    table.insert( self._vEnemiesRemaining, spawnedUnit )
		spawnedUnit:SetDeathXP( 0 )
		spawnedUnit.unitName = spawnedUnit:GetUnitName()
	else
		return
	end
end

function CHoldoutGameRound:OnEntityKilled( event )
	local killedUnit = EntIndexToHScript( event.entindex_killed )
	if not killedUnit then
		return
	end
    if killedUnit:GetUnitName()=="npc_dota_creature_broodking" then
    	  GameRules:SendCustomMessage("#spiderqueendie", 0, 0)
          GameRules:GetGameModeEntity():SetFogOfWarDisabled( true )
    end
	for i, unit in pairs( self._vEnemiesRemaining ) do
		if killedUnit == unit then
			table.remove( self._vEnemiesRemaining, i )
			break
		end
	end	
	if killedUnit.Holdout_IsCore then
		self._nCoreUnitsKilled = self._nCoreUnitsKilled + 1
		self:_CheckForGoldBagDrop( killedUnit )
		LootController:CheckForLootItemDrop(self._nRoundNumber,self._nItemDropNum,self._totalCreatureNum,killedUnit )
        QuestSystem:RefreshQuest("Progress", self._nCoreUnitsKilled,self._nCoreUnitsTotal)
	end

	local attackerUnit = EntIndexToHScript( event.entindex_attacker or -1 )
	if attackerUnit then
		local playerID = attackerUnit:GetPlayerOwnerID()
		local playerStats = self._vPlayerStats[ playerID ]
		if playerStats then
			playerStats.nCreepsKilled = playerStats.nCreepsKilled + 1
			--print("CreepKills"..playerStats.nCreepsKilled)
		end
	end
end

function CHoldoutGameRound:OnHoldoutReviveComplete( event )
	local castingHero = EntIndexToHScript( event.caster )
	if castingHero then
		local nPlayerID = castingHero:GetPlayerOwnerID()
		local playerStats = self._vPlayerStats[ nPlayerID ]
		if playerStats then
			playerStats.nPlayersResurrected = playerStats.nPlayersResurrected + 1
		end
	end
end


function CHoldoutGameRound:OnItemPickedUp( event )
	if event.itemname == "item_bag_of_gold" then
		local playerStats = self._vPlayerStats[ event.PlayerID ]
		if playerStats then
			playerStats.nGoldBagsCollected = playerStats.nGoldBagsCollected + 1
		end
	end
end


function CHoldoutGameRound:_CheckForGoldBagDrop( killedUnit )
	if self._nGoldRemainingInRound <= 0 then
		return
	end

	local nGoldToDrop = 0
	local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
	if nCoreUnitsRemaining <= 0 then
		nGoldToDrop = self._nGoldRemainingInRound
	else
		local flCurrentDropChance = self._nGoldBagsRemaining / (1 + nCoreUnitsRemaining)
		if RandomFloat( 0, 1 ) <= flCurrentDropChance then
			if self._nGoldBagsRemaining <= 1 then
				nGoldToDrop = self._nGoldRemainingInRound
			else
				nGoldToDrop = math.floor( self._nGoldRemainingInRound / self._nGoldBagsRemaining )
				nCurrentGoldDrop = math.max(1, RandomInt( nGoldToDrop - self._nBagVariance, nGoldToDrop + self._nBagVariance  ) )
			end
		end
	end
	
	nGoldToDrop = math.min( nGoldToDrop, self._nGoldRemainingInRound )
	if nGoldToDrop <= 0 then
		return
	end
	self._nGoldRemainingInRound = math.max( 0, self._nGoldRemainingInRound - nGoldToDrop )
	self._nGoldBagsRemaining = math.max( 0, self._nGoldBagsRemaining - 1 )

	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	newItem:SetPurchaseTime( 0 )
	newItem:SetCurrentCharges( nGoldToDrop )
	local drop = CreateItemOnPositionSync( killedUnit:GetAbsOrigin(), newItem )
	local dropTarget = killedUnit:GetAbsOrigin() + RandomVector( RandomFloat( 50, 350 ) )
	newItem:LaunchLoot( true, 300, 0.75, dropTarget )
end


function CHoldoutGameRound:StatusReport( )
	print( string.format( "Enemies remaining: %d", #self._vEnemiesRemaining ) )
	for _,e in pairs( self._vEnemiesRemaining ) do
		if e:IsNull() then
			print( string.format( "<Unit %s Deleted from C++>", e.unitName ) )
		else
			print( e:GetUnitName() )
		end
	end
	print( string.format( "Spawners: %d", #self._vSpawners ) )
	for _,s in pairs( self._vSpawners ) do
		s:StatusReport()
	end
end