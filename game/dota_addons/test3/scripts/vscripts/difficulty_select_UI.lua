PlayersSelectDifficulty = {}
PlayersSelectDifficulty["easy"] = {}
PlayersSelectDifficulty["normal"] = {}
PlayersSelectDifficulty["hard"] = {}
PlayersSelectDifficulty["trial"] = {}


PlayerSelectTrialLevel={}

for i=0,DOTA_MAX_TEAM_PLAYERS-1 do  --人数
	table.insert(PlayerSelectTrialLevel,0)
end


function CHoldoutGameMode:SelectDifficulty( keys )

	if type(keys.difficulty) == "string" then
		local player = PlayerResource:GetPlayer(keys.playerID)
		if player == nil then return end

		local id = keys.playerID + 1

		if keys.difficulty == "easy" then
			for k,v in pairs(PlayersSelectDifficulty) do
				v[id] = nil
			end
			PlayersSelectDifficulty["easy"][id] = true

		elseif keys.difficulty == "normal" then
			for k,v in pairs(PlayersSelectDifficulty) do
				v[id] = nil
			end
			PlayersSelectDifficulty["normal"][id] = true

		elseif keys.difficulty == "hard" then
			for k,v in pairs(PlayersSelectDifficulty) do
				v[id] = nil
			end
			PlayersSelectDifficulty["hard"][id] = true

		elseif keys.difficulty == "trial" then
			for k,v in pairs(PlayersSelectDifficulty) do
				v[id] = nil
			end
			PlayersSelectDifficulty["trial"][id] = true
		end

		CustomGameEventManager:Send_ServerToAllClients("SelectDifficultyReturn",{selectionData=PlayersSelectDifficulty})
	end
end

function CHoldoutGameMode:SetBaseDifficulty()  --设定四种基本难度

	local difficulty = {easy=#PlayersSelectDifficulty["easy"], hard=#PlayersSelectDifficulty["hard"],
	normal=#PlayersSelectDifficulty["normal"],trial=#PlayersSelectDifficulty["trial"]}
	local max = math.max(difficulty.easy,difficulty.normal,difficulty.hard,difficulty.trial)
    
    if GameRules:IsCheatMode() then 
      Notifications:BottomToAll({text="#cheat_mode_warning", duration=10, style={color="Red"}})
    end

	if max == difficulty.normal then
		self.map_difficulty=2
		CustomGameEventManager:Send_ServerToAllClients("AnnounceDifficulty",{difficulty="normal"})
		elseif max == difficulty.hard then
			self.map_difficulty=3
			self.flDDadjust=1.4
	        self.flDHPadjust=1.5
			CustomGameEventManager:Send_ServerToAllClients("AnnounceDifficulty",{difficulty="hard"})
			self:AddHeroDifficultyModifier()
			elseif max == difficulty.easy then
				self.map_difficulty=1
			    self.flDDadjust=0.55
	            self.flDHPadjust=0.75
			    CustomGameEventManager:Send_ServerToAllClients("AnnounceDifficulty",{difficulty="easy"})
			    self:AddHeroDifficultyModifier()
				  elseif max == difficulty.trial then
				   CustomGameEventManager:Send_ServerToAllClients("ShowTrialLevelPanel",{setupTime=self.nTrialSetTime})
				   --具体难度未定
	end
end


function CHoldoutGameMode:AddHeroDifficultyModifier()
	--给英雄加上显示难度的buff
	for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )
				if hero then
				   ability=hero:FindAbilityByName("damage_counter")
				   if ability then
				   	 if self.map_difficulty==1 then
	                  ability:ApplyDataDrivenModifier(hero, hero, "modifier_map_easy_show", {})
	                 end
	                 if self.map_difficulty==3 then
	                  ability:ApplyDataDrivenModifier(hero, hero, "modifier_map_hard_show", {})
	                 end
	                 if self.map_difficulty>3 then
	                  ability:ApplyDataDrivenModifier(hero, hero, "modifier_map_endless_stack", {})
					  hero:SetModifierStackCount("modifier_map_endless_stack",ability, self.map_difficulty-3)
	                 end
	               end
			    end
			end
		end
	end	
end


function CHoldoutGameMode:SendTrialLeveltoServer( keys )
    local iPlayId=tonumber(keys.playerId)
	PlayerSelectTrialLevel[iPlayId]=keys.levelChoose
end


function CHoldoutGameMode:SetTrialMapDifficulty ()
	local sum =0
	local choosedPlayerNumber=0
	for i=0,DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerSelectTrialLevel[i]~=nil and PlayerSelectTrialLevel[i]~=0 then
			choosedPlayerNumber=choosedPlayerNumber+1
			sum=sum+PlayerSelectTrialLevel[i]
	    end
	end
	local average=1 
	if choosedPlayerNumber ~= 0 then
	   average=math.floor(sum/choosedPlayerNumber)
	end

	self.map_difficulty=3+math.floor(average)

    self.flDDadjust=1.5*(1+(self.map_difficulty-3)*0.05)
    self.flDHPadjust=1.5*(1+(self.map_difficulty-3)*0.08)  --rift

    CustomGameEventManager:Send_ServerToAllClients("AnnounceDifficulty",{difficulty="trial",level= tostring(math.floor(average)) })
end
