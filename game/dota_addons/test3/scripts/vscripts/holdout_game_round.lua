--[[	CHoldoutGameRound - A single round of Holdout
]]
require("environment_controller/round_environment_controller")
LinkLuaModifier("modifier_affixes_dilation", "creature_ability/modifier/modifier_affixes_dilation", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_affixes_falling_rock", "creature_ability/modifier/modifier_affixes_falling_rock", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_intellect_reduction", "creature_ability/modifier/modifier_intellect_reduction", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_smoke_breaking_aura", "creature_ability/modifier/modifier_smoke_breaking_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_armor", "creature_ability/modifier/modifier_bonus_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_bonus_magical_resistance", "creature_ability/modifier/modifier_bonus_magical_resistance", LUA_MODIFIER_MOTION_NONE)

if CHoldoutGameRound == nil then
    CHoldoutGameRound = class({})
end

exceptionSpawnedUnit = {   --不计入游戏进度的单位名字，一般是各种马甲单位
    npc_majia_water_1 = true,
    npc_dummy_blank = true,
    npc_dota_thinker = true,
    npc_falling_rock_dummy = true,
    npc_geodesic_dummy = true,
    npc_dota_beastmaster_axe = true,
    npc_dota_creature_affixes_laser_turret = true,
    npc_dota_storegga_rock = true,
    npc_dota_plasma_field = true,
    npc_dota_stormspirit_remnant = true,
    npc_dota_invisible_vision_source = true,
    npc_maze_wall = true,
    bomber_bomb = true,
    stasis_trap = true,
}

function CHoldoutGameRound:ReadConfiguration(kv, gameMode, roundNumber)
    self._gameMode = gameMode
    self._nRoundNumber = roundNumber
    self._szRoundQuestTitle = kv.round_quest_title --round_quest_title 如果kv里面了没填就是nil
    self._szRoundTitle = kv.round_title or string.format("Round%d", roundNumber)
    self._nBonusLevel = tonumber(kv.bonus_level) or roundNumber
    self._alias = kv.alias or string.format("Round%d", roundNumber)   --设置一个别名，方便成就系统
    self._szType = kv.type or 'normal'   --boss/normal 区分是不是BOSS关
    self._not_multiple = true
    self._shortTitle = kv.ShortTitle or ''
    self._nMaxGold = tonumber(kv.MaxGold or 0)
    self._nBagCount = tonumber(kv.BagCount or 0)
    self._nBagVariance = tonumber(kv.BagVariance or 0)
    self._nFixedXP = tonumber(kv.FixedXP or 0)
    self._nItemDropNum = tonumber(kv.ItemDropNum or 8)  --单人玩家一关默认掉落8件物品 ，5人24件
    self._nExpectedGold = tonumber(kv.ExpectedGold or 0)  --预计本关可以取得的金钱
    self._vSpawners = {}
    self._totalCreatureNum = 0
    self._environmentcontroller = EnvironmentController()
    self._environmentcontroller:Init()  --环境控制器初始化
    self._bBossHasSpawned = false

    for k, v in pairs(kv) do
        if type(v) == "table" and v.NPCName then
            local spawner = CHoldoutGameSpawner()
            spawner:ReadConfiguration(k, v, self)
            self._vSpawners[k] = spawner
            if (v.TotalUnitsToSpawn) then   --统计怪物数量，影响物品爆率
                self._totalCreatureNum = self._totalCreatureNum + tonumber(v.TotalUnitsToSpawn)
            end
        end
    end
    for _, spawner in pairs(self._vSpawners) do
        spawner:PostLoad(self._vSpawners)
    end
end


function CHoldoutGameRound:Precache()
    for _, spawner in pairs(self._vSpawners) do
        spawner:Precache()
    end
end

function CHoldoutGameRound:Begin()
    self._vEnemiesRemaining = {}
    self._vEventHandles = {
        ListenToGameEvent("npc_spawned", Dynamic_Wrap(CHoldoutGameRound, "OnNPCSpawned"), self),
        ListenToGameEvent("entity_killed", Dynamic_Wrap(CHoldoutGameRound, "OnEntityKilled"), self),
        ListenToGameEvent("dota_holdout_revive_complete", Dynamic_Wrap(CHoldoutGameRound, 'OnHoldoutReviveComplete'), self)
    }
    self.Begin_Time = GameRules:GetGameTime()
    --self:InitialAcheivementSystem()  --初始化成就系统
    self._vPlayerStats = {}
    self.Palyer_Number = 0
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        self._vPlayerStats[nPlayerID] = {
            nCreepsKilled = 0,
            nTotalDamage = 0,
            nTotalHeal = 0,
            nGoldBagsCollected = 0,
            nPriorRoundDeaths = PlayerResource:GetDeaths(nPlayerID),
            nPlayersResurrected = 0
        }
    end
    --调节人数奖励
    local playernumberbonus = 0.5
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
            if PlayerResource:HasSelectedHero(nPlayerID) then
                playernumberbonus = playernumberbonus + 0.5
                self.Palyer_Number = self.Palyer_Number + 1
            end
        end
    end

    if self._alias == "tidehunter" and self.Palyer_Number > 0 then
        local roundTidehunterTitles = {
            "#DOTA_Holdout_Round_Tidehunter_Title1",
            "#DOTA_Holdout_Round_Tidehunter_Title2",
            "#DOTA_Holdout_Round_Tidehunter_Title3",
            "#DOTA_Holdout_Round_Tidehunter_Title4",
            "#DOTA_Holdout_Round_Tidehunter_Title5"
        }
        self._szRoundTitle = roundTidehunterTitles[self.Palyer_Number]
    end

    GameRules:GetGameModeEntity().Palyer_Number = self.Palyer_Number --更新玩家数量

    if self._not_multiple then
        self._nFixedXP = self._nFixedXP * playernumberbonus
        if self._gameMode.map_difficulty <= 2 then
            self._nFixedXP = self._nFixedXP * 1.5
            if self._gameMode.map_difficulty == 1 then
                self._nFixedXP = self._nFixedXP * 1.5
            end
        end
        self._nMaxGold = self._nMaxGold * playernumberbonus
        self._nItemDropNum = self._nItemDropNum * playernumberbonus
        self._nItemDropNum = math.ceil(self._nItemDropNum * hardLevelItemDropBonus[self._gameMode.map_difficulty])
        self._not_multiple = false  --不重复加成
    end

    self._nGoldRemainingInRound = self._nMaxGold
    self._nGoldBagsRemaining = self._nBagCount
    self._nGoldBagsExpired = 0
    self._nCoreUnitsTotal = 0
    LootController:SetItemProbability(self._nRoundNumber, self._gameMode.map_difficulty)

    local vAffixes_Text = {
        necrotic = "#affixes_necrotic",
        teeming = "#affixes_teeming",
        raging = "#affixes_raging",
        fortify = "#affixes_fortify",
        bolstering = "#affixes_bolstering",
        overflowing = "#affixes_overflowing",
        sanguine = "#affixes_sanguine",
        silence = "#affixes_silence",
        falling_rock = "#affixes_falling_rock",
        spike = "#affixes_spike",
        silver = "#affixes_silver",
        dilation = "#affixes_dilation",
        laser = "#affixes_laser",
        fragile = "#affixes_fragile",
    }
    local vAffixesTooltipAbility = {
        necrotic = "affixes_ability_necrotic",
        teeming = "affixes_ability_tooltip_teeming",
        raging = "affixes_ability_raging",
        fortify = "affixes_ability_fortify",
        bolstering = "affixes_ability_bolstering",
        overflowing = "affixes_ability_tooltip_overflowing",
        sanguine = "affixes_ability_sanguine",
        silence = "affixes_ability_tooltip_silence",
        falling_rock = "affixes_ability_tooltip_falling_rock",
        spike = "affixes_ability_spike",
        -- 银锋 词缀 禁被动
        silver = "affixes_ability_tooltip_silver",
        dilation = "affixes_ability_tooltip_dilation",
        laser = "affixes_ability_tooltip_laser",
        fragile = "affixes_ability_tooltip_fragile",
    }

    -- 确保本轮内不会出现的词缀
    local vRoundExceptionMap = {
        skeleton = "laser",
        bandit = "laser",
        scourge = "laser",
        wolf = "laser",
        tinker = "bolstering",
    }

    -- 确保某轮不出繁盛就不会有某些词缀
    local vRoundSingleBossMap = {
        skywrath = true,
        phoenix = true,
        mammoth = true,
        blue_dragon = true,
        sandking = true,
        ancient_apparition = true,
        tidehunter = true,
        lion = true,
        rubick = true,
    }

    local affixesTooltipAbilityList = {}
    self.bAffixFlag = false   -- 是否初始化过词缀
    self.vAffixes = {
        necrotic = false,
        teeming = false,
        raging = false,
        fortify = false,
        bolstering = false,
        overflowing = false,
        sanguine = false,
        silence = false,
        falling_rock = false,
        spike = false,
        silver = false,
        dilation = false,
        laser = false,
        fragile = false,
    }
    local affixes_temp = {}
    local affixes_number = 0
    -- print("self._gameMode.map_difficulty"..self._gameMode.map_difficulty)
    if self._gameMode.map_difficulty > 8 then  --五层以下试炼没有词缀
        affixes_number = math.floor(Quadric(2.5, -2.5, 8 - self._gameMode.map_difficulty)) --2.5*n(n-1)+5=level  n为词缀数目
    end

    if affixes_number > 0 then

        local affixes_sum = 0

        for k, v in pairs(self.vAffixes) do
            affixes_sum = affixes_sum + 1
        end

        local hasTeeming = false
        -- 先确定有没有繁盛
        if RandomInt(1, affixes_sum) <= affixes_number then
            hasTeeming = true
            affixes_number = affixes_number - 1
        else
            -- 没有繁盛，且为单个 BOSS，血池激励不会出现
            if vRoundSingleBossMap[self._alias] == true then
                self.vAffixes.sanguine = true
                self.vAffixes.bolstering = true
            end
        end

        self.vAffixes.teeming = true

        if vRoundExceptionMap[self._alias] ~= nil then
            self.vAffixes[vRoundExceptionMap[self._alias]] = true
        end

        for k, v in pairs(self.vAffixes) do
            if v == false then
                table.insert(affixes_temp, k)
            end
        end

        self.vAffixes.necrotic = false
        self.vAffixes.raging = false
        self.vAffixes.fortify = false
        self.vAffixes.bolstering = false
        self.vAffixes.overflowing = false
        self.vAffixes.sanguine = false
        self.vAffixes.silence = false
        self.vAffixes.falling_rock = false
        self.vAffixes.spike = false
        self.vAffixes.silver = false
        self.vAffixes.dilation = false
        self.vAffixes.laser = false
        self.vAffixes.fragile = false
        self.vAffixes.teeming = hasTeeming

        for i = 1, affixes_number do
            if #affixes_temp > 0 then
                local random = RandomInt(1, #affixes_temp)
                self.vAffixes[affixes_temp[random]] = true
                table.remove(affixes_temp, random)
            end
        end

        --处理词缀Debuff
        for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
                if PlayerResource:HasSelectedHero(nPlayerID) then
                    local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                    if hero then
                        local ability = hero:FindAbilityByName("damage_counter")
                        if ability then
                            if self.vAffixes.overflowing then
                                AddDataDrivenModifierHelper(hero, ability, "modifier_overflow_show")
                                -- ability:ApplyDataDrivenModifier(hero, hero, "modifier_overflow_show", {})
                            end
                            if self.vAffixes.silence then
                                AddDataDrivenModifierHelper(hero, ability, "modifier_silence_permenant")
                                -- ability:ApplyDataDrivenModifier(hero, hero, "modifier_silence_permenant", {})
                            end
                            if self.vAffixes.silver then
                                AddDataDrivenModifierHelper(hero, ability, "modifier_affixes_silver")
                                -- ability:ApplyDataDrivenModifier(hero, hero, "modifier_affixes_silver", {})
                            end
                            if self.vAffixes.fragile then
                                AddDataDrivenModifierHelper(hero, ability, "modifier_affixes_fragile")
                                -- ability:ApplyDataDrivenModifier(hero, hero, "modifier_affixes_fragile", {})
                            end
                        end
                        if self.vAffixes.dilation then
                            -- hero:AddNewModifier(hero, nil, "modifier_affixes_dilation", {})
                            AddModifierHelper(hero, "modifier_affixes_dilation")
                        end
                        if self.vAffixes.falling_rock then
                            AddModifierHelper(hero, "modifier_affixes_falling_rock")
                        end
                        if self.vAffixes.laser then
                            self._environmentcontroller:AffixesSpawnLaser()
                        end
                    end
                end
            end
        end

        for k, v in pairs(self.vAffixes) do
            if v then
                print(vAffixes_Text[k])
                table.insert(affixesTooltipAbilityList, vAffixesTooltipAbility[k])
                Notifications:BottomToAll({ text = vAffixes_Text[k], duration = 10, style = { color = "Red" }, continue = true })
            end
        end

    end

    for _, spawner in pairs(self._vSpawners) do
        spawner:Begin()
        self._nCoreUnitsTotal = self._nCoreUnitsTotal + spawner:GetTotalUnitsToSpawn()
    end
    self._nCoreUnitsKilled = 0

    QuestSystem:CreateQuest("Progress", "#tws_quest_progress_text", 0, self._nCoreUnitsTotal, nil, self._nRoundNumber)
    if self._szRoundQuestTitle ~= nil then
        local bonusItemName = ""
        local bonusLevel = self._nRoundNumber

        if bonusItems[bonusLevel] ~= nil and #bonusItems[bonusLevel] == 1 then
            bonusItemName = bonusItems[bonusLevel][1]
        else
            bonusItemName = "item_treasure_chest_" .. bonusLevel
        end
        QuestSystem:CreateAchQuest("Achievement", self._szRoundQuestTitle, 1, 1, nil, bonusItemName)
    end
    self:InitialAcheivementSystem()  --初始化成就系统
    if #affixesTooltipAbilityList > 0 then
        QuestSystem:CreatAffixesQuest("Affixes", affixesTooltipAbilityList)
        self.bAffixFlag = true
    end
    CustomGameEventManager:Send_ServerToAllClients("ShowRoundTitle", { roundTitle = self._szRoundTitle })
--[[ 7.07更新后 此方法失效
   local messageinfo = {
           message = self._szRoundTitle,
           duration=6
            }
   FireGameEvent("show_center_message",messageinfo)
   ]]
end


function CHoldoutGameRound:End()
    self._bBossHasSpawned = false
    for _, eID in pairs(self._vEventHandles) do
        StopListeningToGameEvent(eID)
    end
    self._vEventHandles = {}

    for i = 0, self.Palyer_Number - 1 do  --统计伤害 放在这 可以统计到失败的关卡的伤害
        vTotalDamageTable[i] = vTotalDamageTable[i] + self._vPlayerStats[i].nTotalDamage
        vTotalHealTable[i] = vTotalHealTable[i] + self._vPlayerStats[i].nTotalHeal
    end
    --修改娜迦睡怪无法清除问题 +DOTA_UNIT_TARGET_FLAG_INVULNERABLE+DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD
    for _, unit in pairs(FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)) do
        if not unit:IsNull() and unit:IsAlive() then
            --因游戏机制而移除的单位
            unit.removedByMech = true
            if vToRemoveAbilityOnRemoveMap[unit:GetUnitName()] ~= nil then
                unit:RemoveAbility(vToRemoveAbilityOnRemoveMap[unit:GetUnitName()])
            end
            unit:ForceKill(true)
        end
    end

    for _, spawner in pairs(self._vSpawners) do
        spawner:End()
    end

    if self._alias == "warlock" then
        -- 术士关杀掉小小
        local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD, FIND_ANY_ORDER, false)
        for _, unit in pairs(targets) do
            if string.match(unit:GetUnitName(), "npc_dota_tiny_") then
                unit.removedByMech = true
                unit:RemoveAbility("tiny_die_announce")
                unit:ForceKill(true)
            end
        end
    end

    if self._alias == "lion" then   --清理续命神符
        local items = Entities:FindAllByClassname("dota_item_drop")
        for _, item in pairs(items) do
            local containedItem = item:GetContainedItem()
            if containedItem then
                if containedItem:GetAbilityName() == "item_rune_life_extension" then
                    UTIL_Remove(item)
                end
            end
        end
    end

    --删除本轮的UI
    QuestSystem:DelQuest("Progress")
    if self._szRoundQuestTitle ~= nil then
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
    self.achievement_flag = true

    if self._alias == "skeleton" then
        if alreadyCached["npc_dota_hero_necrolyte"] == true then
        else
            PrecacheUnitByNameAsync('npc_precache_npc_dota_hero_necrolyte', function() end)
            alreadyCached["npc_dota_hero_necrolyte"] = true
        end
    end

    if self._alias == "wolf" then  --狼人关处理预载入
        PrecacheResource('particle', 'particles/units/heroes/hero_lycan/lycan_claw_blur.vpcf', context)
        PrecacheResource('particle', 'particles/units/heroes/hero_lycan/lycan_claw_blur_b.vpcf', context)
        PrecacheResource('particle', 'particles/units/heroes/hero_beastmaster/beastmaster_boar_attack.vpcf', context)
    end

    if self._alias == "phoenix" then
        self.achievement_flag = false
        QuestSystem:RefreshAchQuest("Achievement", 0, 6)
    end

    if self._alias == "morphing" then
        QuestSystem:RefreshAchQuest("Achievement", 0, 5)
        self.achievement_flag = false
        local maxReaperNumber = 0
        Timers:CreateTimer({
            endTime = 1,
            callback = function()
                local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
                local reapernumber = 0
                if #targets > 0 then
                    for i, unit in pairs(targets) do
                        if unit:GetUnitName() == "npc_dota_water_3" then
                            reapernumber = reapernumber + 1
                        end
                    end
                end
                if reapernumber > maxReaperNumber and reapernumber < 6 then
                    maxReaperNumber = reapernumber
                    QuestSystem:RefreshAchQuest("Achievement", maxReaperNumber, 5)
                end
                if reapernumber >= 5 then
                    Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, { text = "#round6_acheivement_fail_note", duration = 4, style = { color = "Chartreuse" } })
                    CHoldoutGameMode._currentRound.achievement_flag = true
                    return nil
                end
                if CHoldoutGameMode._currentRound == nil or CHoldoutGameMode._currentRound._alias == "morphing" then
                    return 0.4
                else
                    return nil
                end
            end
        })
    end
    if self._alias == "rattletrap" then
        PrecacheUnitByNameAsync('npc_maze_wall', function() end)
        PrecacheUnitByNameAsync('bomber_bomb', function() end)
        PrecacheUnitByNameAsync('stasis_trap', function() end)
    end
    if self._alias == "warlock" then
        QuestSystem:RefreshAchQuest("Achievement", 0, 1)
        self.achievement_flag = false
        if alreadyCached["npc_dota_hero_razor"] == true then
        else
            PrecacheUnitByNameAsync('npc_precache_npc_dota_hero_razor', function() end)
            alreadyCached["npc_dota_hero_razor"] = true
        end
        PrecacheUnitByNameAsync('npc_dota_tiny_2', function() end)
        PrecacheUnitByNameAsync('npc_dota_tiny_3', function() end)
        PrecacheUnitByNameAsync('npc_dota_tiny_4', function() end)
        PrecacheUnitByNameAsync('npc_dota_tiny_5', function() end)
        local wp = Entities:FindByName(nil, "waypoint_tiny1")
        local entUnit = CreateUnitByName("npc_dota_tiny_1", wp:GetOrigin(), true, nil, nil, DOTA_TEAM_GOODGUYS)
    end
    if self._alias == "mammoth" then
        QuestSystem:RefreshAchQuest("Achievement", 1, 1)
    end
    if self._alias == "blue_dragon" then
        QuestSystem:RefreshAchQuest("Achievement", 1, 1)
    end
    if self._alias == "tree" then
        self.treeElderDieNumber = 0
        QuestSystem:RefreshAchQuest("Achievement", 0, 10)
        self.achievement_flag = false
    end
    if self._alias == "morphing_again" then
        QuestSystem:RefreshAchQuest("Achievement", 0, 20)
        self.achievement_flag = false
        local maxReaperNumber = 0
        Timers:CreateTimer({
            endTime = 1,
            callback = function()
                local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
                local reapernumber = 0
                if #targets > 0 then
                    for i, unit in pairs(targets) do
                        if unit:GetUnitName() == "npc_dota_water_3s" then
                            reapernumber = reapernumber + 1
                        end
                    end
                end
                if reapernumber > maxReaperNumber and reapernumber < 21 then
                    maxReaperNumber = reapernumber
                    QuestSystem:RefreshAchQuest("Achievement", maxReaperNumber, 20)
                end
                if reapernumber >= 20 then
                    Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, { text = "#round12_acheivement_fail_note", duration = 4, style = { color = "Chartreuse" } })
                    CHoldoutGameMode._currentRound.achievement_flag = true
                    return nil
                end
                if CHoldoutGameMode._currentRound == nil or CHoldoutGameMode._currentRound._alias == "morphing_again" then
                    return 0.4
                else
                    return nil
                end
            end
        })
    end
    if self._alias == "darkness" then
        self._environmentcontroller:ApplyBlindModifier()
        self._environmentcontroller:SpawnLightBall()
    end
    if self._alias == "tusk" then
        if alreadyCached["npc_dota_hero_tusk"] == true then
        else
            PrecacheUnitByNameAsync('npc_dota_hero_tusk', function() end)
            alreadyCached["npc_dota_hero_tusk"] = true
        end
        if alreadyCached["npc_dota_hero_earth_spirit"] == true then
        else
            PrecacheUnitByNameAsync('npc_dota_hero_earth_spirit', function() end)
            alreadyCached["npc_dota_hero_earth_spirit"] = true
        end
    end
    if self._alias == "alchemist" then
        if alreadyCached["npc_dota_hero_alchemist"] == true then
        else
            PrecacheUnitByNameAsync('npc_dota_hero_alchemist', function() end)
            alreadyCached["npc_dota_hero_alchemist"] = true
        end
    end
    if self._alias == "nyx" then
        if alreadyCached["npc_dota_hero_nyx_assassin"] == true then
        else
            PrecacheUnitByNameAsync('npc_dota_hero_nyx_assassin', function() end)
            alreadyCached["npc_dota_hero_nyx_assassin"] = true
        end
    end
    if self._alias == "faceless" then   --如果是无面者，加上黑暗信标
        self._environmentcontroller:ApplyBeaconModifier()
    end
    if self._alias == "tinker" then   --如果是TK关 预载入TK资源
        if alreadyCached["npc_dota_hero_tinker"] == true then
        else
            PrecacheUnitByNameAsync('npc_dota_hero_tinker', function() end)
            alreadyCached["npc_dota_hero_tinker"] = true
        end
        PrecacheUnitByNameAsync('npc_dota_creature_techies_suicider', function() end) --预载入炸弹人
    end
    if self._alias == "tombstone" then --刷新墓碑
        self._environmentcontroller.tombInterval = 15
        self._environmentcontroller:SpawnTombStone()
    end
end



function CHoldoutGameRound:Special_Reward(round_number)
    Timers:CreateTimer(4, function()
        local middle_dummy = Entities:FindByName(nil, "dummy_middle")
        local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, middle_dummy)
        ParticleManager:ReleaseParticleIndex(particle)
        local spawnPoint = middle_dummy:GetAbsOrigin()
        local newItem = CreateItem("item_treasure_chest_" .. round_number, nil, nil)
        local drop = CreateItemOnPositionForLaunch(spawnPoint, newItem)
        newItem:LaunchLootInitialHeight(false, 0, 200, 0.25, spawnPoint)
        EmitGlobalSound("Hero_LegionCommander.Duel.Victory")
    end)
end


function CHoldoutGameRound:Think()
    for _, spawner in pairs(self._vSpawners) do
        spawner:Think()
    end
end


function CHoldoutGameRound:ChooseRandomSpawnInfo()
    return self._gameMode:ChooseRandomSpawnInfo()
end

function CHoldoutGameRound:ChooseRandomSpawnInfoForBigGuy()
    return self._gameMode:ChooseRandomSpawnInfoForBigGuy()
end


function CHoldoutGameRound:IsFinished()
    for _, spawner in pairs(self._vSpawners) do
        if not spawner:IsFinishedSpawning() then
            return false
        end
    end

    local nEnemiesRemaining = #self._vEnemiesRemaining
    if nEnemiesRemaining == 0 then
        if not self._bBossHasSpawned and (self._alias == "invoker" or self._alias == "rubick") then
            self:SpawnBoss()
            if self.vAffixes.teeming then
                self:SpawnBoss()
            end
            return false
        end
        return true
    end

    --print("unit number is"..nEnemiesRemaining)
    --DeepPrint(self._vEnemiesRemaining)
    if not self._lastEnemiesRemaining == nEnemiesRemaining then
        self._lastEnemiesRemaining = nEnemiesRemaining
        print(string.format("%d enemies remaining in the round...", #self._vEnemiesRemaining))
    end
    return false
end


function CHoldoutGameRound:SpawnBoss()
    local entities_dummy = Entities:FindByName(nil, "dummy_middle")
    local spawnPoint = entities_dummy:GetAbsOrigin()
    if self._alias == "invoker" then
        local hInvoker = CreateUnitByName("npc_dota_creature_boss_invoker", spawnPoint, true, nil, nil, DOTA_TEAM_BADGUYS)
        if hInvoker ~= nil then
            for i = 0, 30 - 1 do
                local hAbility = hInvoker:GetAbilityByIndex(i)
                while hAbility and hAbility:CanAbilityBeUpgraded() == ABILITY_CAN_BE_UPGRADED do
                    hAbility:UpgradeAbility(true)
                end
            end

            hInvoker:SetUnitCanRespawn(true)
        end
    elseif self._alias == "rubick" then
        local hRubick = CreateUnitByName("npc_dota_boss_rubick", spawnPoint, true, nil, nil, DOTA_TEAM_BADGUYS)
        if hRubick ~= nil then
            for i = 0, 30 - 1 do
                local hAbility = hRubick:GetAbilityByIndex(i)
                while hAbility and hAbility:CanAbilityBeUpgraded() == ABILITY_CAN_BE_UPGRADED do
                    hAbility:UpgradeAbility(true)
                end
                if hAbility ~= nil and (hAbility:GetAbilityName() == "invoker_wex" or hAbility:GetAbilityName() == "invoker_exort") then
                    hAbility:SetHidden(true)
                end
            end

            hRubick:SetUnitCanRespawn(true)
        end
    end
    self._bBossHasSpawned = true
end


-- Rather than use the xp granting from the units keyvalues file,
-- we let the round determine the xp per unit to grant as a flat value.
-- This is done to make tuning of rounds easier.
function CHoldoutGameRound:GetXPPerCoreUnit()
    if self._nCoreUnitsTotal == 0 then
        return 0
    else
        return math.floor(self._nFixedXP / self._nCoreUnitsTotal)
    end
end


function CHoldoutGameRound:GetBasicBountyPerCoreUnit()
    if self._nCoreUnitsTotal == 0 then
        return 0
    else
        return math.floor(self._nMaxGold * 0.25 / self._nCoreUnitsTotal) --金币的1/4作为怪的基础金币奖励
    end
end

smokeBreakingUnit = {   -- 可以破雾的单位
    npc_dota_creature_exort_invoker = true,
    npc_dota_creature_quas_invoker = true,
    npc_dota_creature_wex_invoker = true,
    npc_dota_creature_boss_invoker = true,
    npc_dota_boss_rubick = true,
}

function CHoldoutGameRound:OnNPCSpawned(event)
    local spawnedUnit = EntIndexToHScript(event.entindex)
    if not spawnedUnit or spawnedUnit:IsPhantom() or exceptionSpawnedUnit[spawnedUnit:GetUnitName()] or spawnedUnit:GetUnitName() == "" or spawnedUnit:IsSummoned() then
        return
    end

    if spawnedUnit:GetTeamNumber() == DOTA_TEAM_BADGUYS then
        spawnedUnit:SetMustReachEachGoalEntity(true)
        table.insert(self._vEnemiesRemaining, spawnedUnit)
        spawnedUnit:SetDeathXP(0)
        spawnedUnit.unitName = spawnedUnit:GetUnitName()
        local armor = spawnedUnit:GetPhysicalArmorBaseValue()
        local magical_res = spawnedUnit:GetBaseMagicalResistanceValue()
        if armor > 30 then
            local base_armor = math.floor(armor * 0.2)
            spawnedUnit:SetPhysicalArmorBaseValue(base_armor)
            local modifier = spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_bonus_armor", {})
            modifier:SetStackCount(armor - base_armor)
        end
        if magical_res > 25 then
            local base_magical_res = math.floor(magical_res * 0.3)
            spawnedUnit:SetBaseMagicalResistanceValue(base_magical_res)
            local modifier = spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_bonus_magical_resistance", {})
            modifier:SetStackCount(math.ceil(100 - (100 - magical_res) / (100 - base_magical_res) * 100))
        end
        if smokeBreakingUnit[spawnedUnit.unitName] then
            spawnedUnit:AddNewModifier(spawnedUnit, nil, "modifier_smoke_breaking_aura", {})
        end
    else
        return
    end
end

function CHoldoutGameRound:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)
    if not killedUnit then
        return
    end
    if killedUnit:GetUnitName() == "npc_dota_creature_broodking" then
        --GameRules:SendCustomMessage("#spiderqueendie", 0, 0)
        --GameRules:GetGameModeEntity():SetFogOfWarDisabled( true )
    end
    for i, unit in pairs(self._vEnemiesRemaining) do
        if killedUnit == unit then
            table.remove(self._vEnemiesRemaining, i)
            break
        end
    end
    if killedUnit.Holdout_IsCore then
        self._nCoreUnitsKilled = self._nCoreUnitsKilled + 1
        self:_CheckForGoldBagDrop(killedUnit)
        LootController:CheckForLootItemDrop(self._nRoundNumber, self._nItemDropNum, self._totalCreatureNum, killedUnit)
        QuestSystem:RefreshQuest("Progress", self._nCoreUnitsKilled, self._nCoreUnitsTotal)

        -- 在简单和普通难度所有玩家平分怪物经验
        if self._gameMode.map_difficulty < 3 then
            for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
                if PlayerResource:IsValidPlayer(nPlayerID) and PlayerResource:HasSelectedHero(nPlayerID) then
                    local state = PlayerResource:GetConnectionState(nPlayerID)
                    if state == DOTA_CONNECTION_STATE_CONNECTED then
                        local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                        if hero:GetTeamNumber() == DOTA_TEAM_GOODGUYS then
                            hero:AddExperience(math.ceil(self:GetXPPerCoreUnit() / self.Palyer_Number), DOTA_ModifyXP_CreepKill, false, true)
                        end
                    end
                end
            end
        end

    end

    local attackerUnit = EntIndexToHScript(event.entindex_attacker or -1)
    if attackerUnit then
        local playerID = attackerUnit:GetPlayerOwnerID()
        local playerStats = self._vPlayerStats[playerID]
        if playerStats then
            playerStats.nCreepsKilled = playerStats.nCreepsKilled + 1
            --print("CreepKills"..playerStats.nCreepsKilled)
        end
    end
end

function CHoldoutGameRound:OnHoldoutReviveComplete(event)
    local castingHero = EntIndexToHScript(event.caster)
    if castingHero then
        local nPlayerID = castingHero:GetPlayerOwnerID()
        local playerStats = self._vPlayerStats[nPlayerID]
        if playerStats then
            playerStats.nPlayersResurrected = playerStats.nPlayersResurrected + 1
        end
    end
end


function CHoldoutGameRound:_CheckForGoldBagDrop(killedUnit)
    if self._nGoldRemainingInRound <= 0 then
        return
    end

    local nGoldToDrop = 0
    local nCoreUnitsRemaining = self._nCoreUnitsTotal - self._nCoreUnitsKilled
    if nCoreUnitsRemaining <= 0 then
        nGoldToDrop = self._nGoldRemainingInRound
    else
        local flCurrentDropChance = self._nGoldBagsRemaining / (1 + nCoreUnitsRemaining)
        if RandomFloat(0, 1) <= flCurrentDropChance then
            if self._nGoldBagsRemaining <= 1 then
                nGoldToDrop = self._nGoldRemainingInRound
            else
                nGoldToDrop = math.floor(self._nGoldRemainingInRound / self._nGoldBagsRemaining)
                nCurrentGoldDrop = math.max(1, RandomInt(nGoldToDrop - self._nBagVariance, nGoldToDrop + self._nBagVariance))
            end
        end
    end

    nGoldToDrop = math.min(nGoldToDrop, self._nGoldRemainingInRound)
    if nGoldToDrop <= 0 then
        return
    end
    self._nGoldRemainingInRound = math.max(0, self._nGoldRemainingInRound - nGoldToDrop)
    self._nGoldBagsRemaining = math.max(0, self._nGoldBagsRemaining - 1)

    local newItem = CreateItem("item_bag_of_gold_tws", nil, nil)
    newItem:SetPurchaseTime(0)
    newItem:SetCurrentCharges(nGoldToDrop)
    newItem.nGoldToDrop = nGoldToDrop
    local drop = CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), newItem)
    local dropTarget = killedUnit:GetAbsOrigin() + RandomVector(RandomFloat(50, 350))
    newItem:LaunchLoot(false, 300, 0.75, dropTarget)  --第一个参数true自动触发
end


function CHoldoutGameRound:StatusReport()
    print(string.format("Enemies remaining: %d", #self._vEnemiesRemaining))
    for _, e in pairs(self._vEnemiesRemaining) do
        if e:IsNull() then
            print(string.format("<Unit %s Deleted from C++>", e.unitName))
        else
            print(e:GetUnitName())
        end
    end
    print(string.format("Spawners: %d", #self._vSpawners))
    for _, s in pairs(self._vSpawners) do
        s:StatusReport()
    end
end