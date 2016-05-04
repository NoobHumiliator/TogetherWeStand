PlayersSelectDifficulty = {}
PlayersSelectDifficulty["easy"] = {}
PlayersSelectDifficulty["normal"] = {}
PlayersSelectDifficulty["hard"] = {}



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
		end

		CustomGameEventManager:Send_ServerToAllClients("SelectDifficultyReturn",{selectionData=PlayersSelectDifficulty})
	end
end

function CHoldoutGameMode:SetDifficulty()

	local difficulty = {easy=#PlayersSelectDifficulty["easy"], hard=#PlayersSelectDifficulty["hard"],
	normal=#PlayersSelectDifficulty["normal"]}
	local max = math.max(difficulty.easy,difficulty.normal,difficulty.hard)

	if max == difficulty.normal then
		self.map_difficulty=2
		CustomGameEventManager:Send_ServerToAllClients("AnnounceDifficulty",{difficulty="normal"})
		elseif max == difficulty.hard then
			self.map_difficulty=3
			CustomGameEventManager:Send_ServerToAllClients("AnnounceDifficulty",{difficulty="hard"})
			elseif max == difficulty.easy then
				self.map_difficulty=1
			  CustomGameEventManager:Send_ServerToAllClients("AnnounceDifficulty",{difficulty="easy"})
	end
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
                   end
			    end
			end
		end
	end	
end

