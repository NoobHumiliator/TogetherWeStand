--[[	Underscore prefix such as "_function()" denotes a local function and is used to improve readability
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

testMode = false
--testMode=true --减少刷兵间隔，增加初始金钱
goldTestMode = false
--goldTestMode=true --需要测试金币相关的内容
require("holdout_game_round")
require("holdout_game_spawner")
require("util")
require("timers")
require("spell_shop_UI")
require("loot_controller")
require("difficulty_select_UI")
require("global_setting")
require("libraries/notifications")
require("filter/damage_filter")
require("filter/order_filter")
require("filter/modifier_gain_filter")
require("quest_system")
require("vip/extra_particles")
require("server/rank")
require("server/detail")
require("server/patreon")
require("server/vip")
require("server/taobao")
require("server/gamesaver")
require("vip/courier")
require("vip/econ_manager")
require("vip/vip_reward")
require("talent_modifiers")
require("item_ability/item_mulberry")

if IsClient() then	-- Load clientside utility lib
    require("client_util")
end

-- Precache resources
-- Actually make the game mode when we activate
function Activate()
    CHoldoutGameMode:InitGameMode()
end

function Precache(context)
    PrecacheResource("particle", "particles/items_fx/aegis_respawn.vpcf", context)
    PrecacheResource("particle", "particles/neutral_fx/roshan_spawn.vpcf", context)
    PrecacheResource("particle", "particles/items2_fx/veil_of_discord.vpcf", context)
    PrecacheResource("particle_folder", "particles/frostivus_gameplay", context)

    --Vip特效
    PrecacheResource('particle', 'particles/econ/courier/courier_trail_lava/courier_trail_lava.vpcf', context)
    PrecacheResource('particle', 'particles/econ/paltinum_baby_roshan/paltinum_baby_roshan.vpcf', context)
    PrecacheResource('particle', 'particles/econ/legion_wings/legion_wings.vpcf', context)
    PrecacheResource('particle', 'particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf', context)
    PrecacheResource('particle', 'particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_ground.vpcf', context)
    PrecacheResource('particle', 'particles/econ/courier/courier_greevil_green/courier_greevil_green_ambient_3.vpcf', context)
    PrecacheResource('particle', 'particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf', context)
    PrecacheResource('particle', 'particles/econ/courier/courier_sappling/courier_sappling_ambient_fly_lvl1.vpcf', context)
    PrecacheResource('particle', 'particles/econ/courier/courier_greevil_red/courier_greevil_red_ambient_3.vpcf', context)
    PrecacheResource('particle', 'particles/econ/courier/courier_trail_orbit/courier_trail_orbit.vpcf', context)

    --学了立即产生例子特效的技能需要预加载,否则闪退
    PrecacheResource('particle', 'particles/units/heroes/hero_spirit_breaker/spirit_breaker_haste_owner.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_huskar/huskar_berserker_blood_hero_effect.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_huskar/huskar_berserkers_blood_glow.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_meepo/meepo_geostrike_ambient.vpcf', context)
    PrecacheResource('particle', 'particles/units/heroes/hero_luna/luna_ambient_lunar_blessing.vpcf', context)
    
    --自定义技能的 光环类特效也必须 提前预加载 否则闪退
    PrecacheResource('particle', 'particles/units/heroes/hero_drow/drow_aura_buff.vpcf', context)


    PrecacheItemByNameSync("item_tombstone", context)
    PrecacheItemByNameSync("item_bag_of_gold_tws", context)
    PrecacheItemByNameSync("item_skysong_blade", context)
    PrecacheItemByNameSync("item_slippers_of_halcyon", context)
    PrecacheItemByNameSync("item_greater_clarity", context)
    PrecacheItemByNameSync("item_unholy", context)
    PrecacheItemByNameSync("item_fallen_sword", context)
    PrecacheItemByNameSync("item_redblade_armor", context)
    PrecacheItemByNameSync("item_mage_shield_1", context)
    PrecacheItemByNameSync("item_treasure_chest_1", context)
    PrecacheItemByNameSync("item_treasure_chest_2", context)
    PrecacheItemByNameSync("item_treasure_chest_3", context)
    PrecacheItemByNameSync("item_treasure_chest_4", context)
    PrecacheItemByNameSync("item_treasure_chest_5", context)
    PrecacheItemByNameSync("item_treasure_chest_6", context)
    PrecacheItemByNameSync("item_treasure_chest_7", context)
    PrecacheItemByNameSync("item_treasure_chest_8", context)
    PrecacheUnitByNameAsync('npc_dota_tiny_1', function() end)


    -- 圣地
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_earthshaker.vsndevts", context)
    --PrecacheResource("soundfile", "soundevents/game_sounds_winter_2018.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_creeps.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_greevils.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_undying.vsndevts", context)

    -- 圣地 Round 3
    PrecacheUnitByNameSync("npc_dota_creature_multiplying_eidelon", context)
    PrecacheUnitByNameSync("npc_dota_creature_jakiro", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_jakiro", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earthshaker/earthshaker_totem_cast.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earthshaker/earthshaker_totem_buff.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_earthshaker/earthshaker_totem_hero_effect.vpcf", context)

    -- 圣地 Round 4
    PrecacheUnitByNameSync("npc_dota_creature_small_ogre_seal", context)
    PrecacheUnitByNameSync("npc_dota_creature_large_ogre_seal", context)
    PrecacheResource("particle", "particles/creatures/ogre_seal/ogre_seal_warcry.vpcf", context)

    -- 圣地 Round 6
    PrecacheResource("particle", "particles/waves/infernal/invoker_forged_spirit_projectile_2.vpcf", context)
    PrecacheResource("particle", "particles/waves/infernal/infernal_siege_fireball.vpcf", context)
    PrecacheResource("particle", "particles/creatures/doomling/impending_doom_overhead.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_doom_bringer/doom_bringer_doom.vpcf", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_doom", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_doombringer.vsndevts", context)
    PrecacheUnitByNameSync("npc_dota_creature_forge_tank", context)
    PrecacheUnitByNameSync("npc_dota_creature_doomling", context)
    PrecacheUnitByNameSync("npc_dota_creature_doomling_champion", context)

    -- 圣地 Round 8
    PrecacheUnitByNameSync("npc_dota_creature_medium_spectre", context)
    PrecacheResource("particle", "particles/dark_moon/darkmoon_creep_warning.vpcf", context)
    PrecacheResource("particle", "particles/creatures/spectre/spectre_active_dispersion.vpcf", context)
    PrecacheResource("particle", "particles/creatures/spectre/spectre_damage_ring.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_templar_assassin/templar_assassin_refraction.vpcf", context)
    PrecacheResource("particle", "particles/creatures/spectre/spectre_blademail.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_razor/razor_base_attack_impact.vpcf", context)

    -- 圣地 Round 9
    PrecacheUnitByNameSync("npc_dota_creature_kobold_overboss", context)
    PrecacheUnitByNameSync("npc_dota_creature_snowball_tuskar", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_faceless_void.vsndevts", context)
    PrecacheResource("particle_folder", "particles/units/creatures", context)
    PrecacheResource("particle", "particles/units/heroes/hero_faceless_void/faceless_void_time_walk.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_faceless_void/faceless_void_time_walk_preimage.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_faceless_void/faceless_void_time_walk_slow.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_tusk.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_tusk/portrait_tusk.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_walruskick_tgt_status.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_walruskick_tgt.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_tusk/tusk_walruskick_txt_ult.vpcf", context)

    -- 圣地 Round 11
    PrecacheUnitByNameSync("npc_dota_creature_frostbitten_melee", context)
    PrecacheUnitByNameSync("npc_dota_creature_large_elder_titan", context)
    PrecacheUnitByNameSync("npc_dota_creature_medium_ancient_apparition", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context)
    PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter_move.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_earth_splitter.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cast_combined.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_cast_combined_detail.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_physical.vpcf", context)
    PrecacheResource("particle", "particles/units/heroes/hero_elder_titan/elder_titan_echo_stomp_magical.vpcf", context)

    -- 圣地 Round 12
    PrecacheUnitByNameSync("npc_dota_creature_storegga", context)
    PrecacheUnitByNameSync("npc_dota_creature_medium_storegga", context)
    PrecacheUnitByNameSync("npc_dota_creature_small_storegga", context)
    PrecacheUnitByNameSync("npc_dota_storegga_rock", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_luna", context)
    PrecacheResource("particle", "particles/act_2/storegga_spawn.vpcf", context)
    PrecacheResource("particle", "particles/act_2/storegga_channel.vpcf", context)

    -- 圣地 Round 13
    PrecacheResource("model", "models/items/storm_spirit/storm_spring_armor/storm_spring_armor.vmdl", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_stormspirit", context)
    PrecacheResource("particle", "particles/creatures/mini_zeus/mini_zeus_lightning_preview.vpcf", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_stormspirit.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_zuus.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_brewmaster.vsndevts", context)

    -- 圣地 Round 14
    PrecacheUnitByNameSync("npc_dota_creature_arc_warden_attacker", context)
    PrecacheUnitByNameSync("npc_dota_creature_arc_warden_support", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_techies.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_arc_warden.vsndevts", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_arc_warden", context)
    PrecacheResource("particle", "particles/econ/items/puck/puck_alliance_set/puck_illusory_orb_aproset.vpcf", context)
    PrecacheResource("particle", "particles/creatures/test/fireball_machine_gun.vpcf", context)
    PrecacheResource("particle", "particles/creatures/test/fireball_machine_gun_building_impact_mechanical.vpcf", context)

    -- 暗月 Round 15
    PrecacheResource("particle_folder", "particles/units/heroes/hero_invoker", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_elder_titan", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_doom_bringer", context)
    PrecacheResource("particle_folder", "particles/units/heroes/hero_ancient_apparition", context)
    PrecacheUnitByNameSync("npc_dota_creature_boss_invoker_forged_spirit", context, -1)
    PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_invoker.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_invoker.vsndevts", context)
    PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_ancient_apparition.vsndevts", context)

    -- Boss Rubick
    if GameRules:IsCheatMode() then
        PrecacheResource("particle_folder", "particles/units/heroes/hero_windrunner", context)
        PrecacheResource("particle_folder", "particles/units/heroes/hero_rubick", context)
        PrecacheResource("particle_folder", "particles/units/heroes/keeper_of_the_light", context)
        PrecacheResource("particle_folder", "particles/rubick_boss", context)
        PrecacheResource("model", "models/heroes/rubick/rubick_staff.vmdl", context)
        PrecacheResource("model", "models/heroes/rubick/cape.vmdl", context)
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_keeper_of_the_light.vsndevts", context)
        PrecacheUnitByNameSync("npc_dota_creature_rubick_melee_creep", context, -1)
        PrecacheUnitByNameSync("npc_dota_boss_rubick", context, -1)
        PrecacheResource("particle", "particles/status_fx/status_effect_dark_seer_illusion.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/hero_windrunner/windrunner_spell_powershot_rubick.vpcf", context)
        PrecacheResource("soundfile", "soundevents/voscripts/game_sounds_vo_rubick.vsndevts", context)
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_rubick.vsndevts", context)
        PrecacheResource("model", "models/items/rubick/rubick_arcana/rubick_arcana_back.vmdl", context)
        PrecacheResource("model", "models/items/rubick/rubick_arcana/rubick_arcana_base.vmdl", context)
        PrecacheResource("model", "models/items/rubick/rubick_ti8_immortal_shoulders/rubick_ti8_immortal_shoulders.vmdl", context)
        PrecacheResource("model", "models/items/rubick/force_staff/force_staff.vmdl", context)
        PrecacheResource("model", "models/heroes/rubick/shoulder.vmdl", context)
        PrecacheResource("model", "models/heroes/rubick/rubick_head.vmdl", context)
        PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_chaos_meteor_fly.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_thundergods_wrath.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_freezing_field_snow.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/heroes_underlord/abyssal_underlord_darkrift_target.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_rain_of_chaos_start.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/hero_rubick/rubick_rain_of_chaos.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/hero_queenofpain/queen_blink_start.vpcf", context)
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_crystalmaiden.vsndevts", context)
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_abyssal_underlord.vsndevts", context)
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_warlock.vsndevts", context)
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_skywrath_mage.vsndevts", context)
        PrecacheResource("soundfile", "soundevents/game_sounds_heroes/game_sounds_kunkka.vsndevts", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_arcana/rubick_arc_spell_steal_default.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_arcana/rubick_arc_ambient_lines.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_arcana/rubick_arc_ambient_default.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_force_ambient/rubick_force_ambient.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_force_ambient/rubick_staff_ambient_kill.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_force.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_land_force.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_force_ambient/rubick_telekinesis_marker_force.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_arcana/rbck_arc_kunkka_ghost_ship.vpcf", context)
        PrecacheResource("particle", "particles/units/heroes/hero_kunkka/kunkka_ghostship_marker.vpcf", context)
        PrecacheResource("particle", "particles/econ/items/rubick/rubick_arcana/rbck_arc_skywrath_mage_mystic_flare_ambient.vpcf", context)
        PrecacheResource("particle", "particles/rubick/rubick_frosthaven_cube_projectile.vpcf", context)
        PrecacheResource("particle", "particles/rubick/rubick_frosthaven_spellsteal.vpcf", context)
    end
    -- 修复对海民放链接闪退
    PrecacheResource("model", "models/heroes/tuskarr/tuskarr_sigil.vmdl", context)
end



function CHoldoutGameMode:InitGameMode()

    GameRules:GetGameModeEntity().CHoldoutGameMode = self
    LinkLuaModifier("modifier_increase_total_damage_lua", "abilities/modifier_increase_total_damage_lua", LUA_MODIFIER_MOTION_NONE)
    Timers:start()
    LootController:ReadConfigration()
    self.bGameStarted = false
    self.loseflag = 0
    self.last_live = 5
    self._nRoundNumber = 1
    self._nBranchIndex = 1 --下一关的分支编号
    self._currentRound = nil
    self._flLastThinkGameTime = nil
    self:_ReadGameConfiguration()
    self.itemSpawnIndex = 1
    self.flProgressTime = 0 --记录progress阶段开始时间
    self.flDDadjust = 1  --保存难度产生的伤害系数修正
    self.flDHPadjust = 1  --保存难度产生的血量系数修正
    self.nTrialSetTime = 12
    self.vipMap = {}  --key是steamID vlaue是vip等级初始化是0
    self.steamIdMap = {}  --key是steamID vlaue是nPlayerNumber
    self.vRoundSkip = {}   --key是Round Number --value是跳关等级
    self.nGoldToCompensate = 0 --跳关待补偿金币
    self.nExpToCompensate = 0 --跳关待补偿经验
    self.bLoadFlag = false --读盘的游戏不能上天梯 全局变量
    self.bTestMode = testMode --全局变量存一下是不是测试模式
    self.nLoadTime = 0  --第几次读档
    self.vXPBeforeMap = {}  --key是nPlayerId value是读档之前已经有的经验
    self.vSelectionData = {} --key为playerId value为所选分支
    self.bRandomRound = false  --本轮是否处于随机

    self.nTimeCost = 0 --统计用时
    Timers:CreateTimer(function() --设置计时器
        self.nTimeCost = self.nTimeCost + 1
        return 1
    end)

    -- 暂时只在测试模式放出奥术神符
    if not GameRules:IsCheatMode() then
        GameRules:GetGameModeEntity():SetRuneEnabled(DOTA_RUNE_ARCANE, false)
    end
    GameRules:GetGameModeEntity():SetRuneEnabled(DOTA_RUNE_BOUNTY, false)
    GameRules:SetRuneMinimapIconScale(0.7)
    GameRules:SetRuneSpawnTime(240)

    GameRules:SetTimeOfDay(0.75)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    GameRules:SetHeroRespawnEnabled(true)
    GameRules:GetGameModeEntity():SetFixedRespawnTime(99999999999)
    GameRules:SetUseUniversalShopMode(true)
    GameRules:SetHeroSelectionTime(35)
    GameRules:SetStrategyTime(0)
    GameRules:SetShowcaseTime(0)
    GameRules:SetFirstBloodActive(false)

    if testMode and not IsDedicatedServer() then  --单机模式 并且开启了测试
        GameRules:SetPreGameTime(3)
        if goldTestMode then
            GameRules:SetGoldTickTime(0.5)
            GameRules:SetGoldPerTick(10000)
        end
        self.nTrialSetTime = 2
    else
        GameRules:SetPreGameTime(15)
        GameRules:SetGoldTickTime(60)
        GameRules:SetGoldPerTick(0)
    end
    GameRules:SetPostGameTime(10)
    GameRules:SetTreeRegrowTime(35)
    GameRules:SetHeroMinimapIconScale(0.7)
    GameRules:SetCreepMinimapIconScale(0.7)
    GameRules:SetRuneMinimapIconScale(0.7)
    GameRules:GetGameModeEntity():SetUseCustomHeroLevels(true)
    GameRules:GetGameModeEntity():SetCustomHeroMaxLevel(999)
    local xpTable = {}
    xpTable[0] = 0
    xpTable[1] = 200
    for i = 2, 1000 do
        xpTable[i] = xpTable[i - 1] + i * 100
    end
    GameRules:GetGameModeEntity():SetCustomXPRequiredToReachNextLevel(xpTable)
    --分身跳出问题
    --GameRules:GetGameModeEntity():SetRemoveIllusionsOnDeath( true )
    GameRules:GetGameModeEntity():SetTopBarTeamValuesOverride(true)
    GameRules:GetGameModeEntity():SetTopBarTeamValuesVisible(false)
    -- Custom console commands
    Convars:RegisterCommand("test_round", function(...) return self:_TestRoundConsoleCommand(...) end, "Test a round of holdout.", FCVAR_CHEAT)
    Convars:RegisterCommand("status_report", function(...) return self:_StatusReportConsoleCommand(...) end, "Report the status of the current holdout game.", FCVAR_CHEAT)
    Convars:RegisterCommand("list_modifiers", function(...) return self:_ListModifiers(...) end, "List modifiers of all hero.", FCVAR_CHEAT)
    --UI交互
    CustomGameEventManager:RegisterListener("AddAbility", Dynamic_Wrap(CHoldoutGameMode, 'AddAbility'))
    CustomGameEventManager:RegisterListener("RemoveAbility", Dynamic_Wrap(CHoldoutGameMode, 'RemoveAbility'))
    CustomGameEventManager:RegisterListener("LevelUpAttribute", Dynamic_Wrap(CHoldoutGameMode, 'LevelUpAttribute'))
    CustomGameEventManager:RegisterListener("PointToGold", Dynamic_Wrap(CHoldoutGameMode, 'PointToGold'))
    CustomGameEventManager:RegisterListener("ConfirmParticle", Dynamic_Wrap(CHoldoutGameMode, 'ConfirmParticle'))
    CustomGameEventManager:RegisterListener("CancleParticle", Dynamic_Wrap(CHoldoutGameMode, 'CancleParticle'))
    
    CustomGameEventManager:RegisterListener("ConfirmCourier", Dynamic_Wrap(CHoldoutGameMode, 'ConfirmCourier'))

    CustomGameEventManager:RegisterListener("GrantCourierAbility", Dynamic_Wrap(CHoldoutGameMode, 'GrantCourierAbility'))
    CustomGameEventManager:RegisterListener("SaveGame", Dynamic_Wrap(CHoldoutGameMode, 'SaveGame'))
    CustomGameEventManager:RegisterListener("AcceptToLoadGame", Dynamic_Wrap(CHoldoutGameMode, 'AcceptToLoadGame'))
    CustomGameEventManager:RegisterListener("PrepareToLoadGame", Dynamic_Wrap(CHoldoutGameMode, 'PrepareToLoadGame'))

    CustomGameEventManager:RegisterListener("SelectDifficulty", Dynamic_Wrap(CHoldoutGameMode, 'SelectDifficulty'))
    CustomGameEventManager:RegisterListener("SelectBranch", Dynamic_Wrap(CHoldoutGameMode, 'SelectBranch')) --选择分支完毕


    CustomGameEventManager:RegisterListener("SendTrialLeveltoServer", Dynamic_Wrap(CHoldoutGameMode, 'SendTrialLeveltoServer'))

    CustomGameEventManager:RegisterListener("ReceiveVipQureySuccess", Dynamic_Wrap(CHoldoutGameMode, 'ReceiveVipQureySuccess'))

    -- Hook into game events allowing reload of functions at run time
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(CHoldoutGameMode, "OnNPCSpawned"), self)
    --ListenToGameEvent( "npc_replaced", Dynamic_Wrap( CHoldoutGameMode, "OnNPCReplaced" ), self )
    --ListenToGameEvent( "dota_player_used_ability", Dynamic_Wrap( CHoldoutGameMode, "OnUseAbility" ), self )
    ListenToGameEvent("player_reconnected", Dynamic_Wrap(CHoldoutGameMode, "OnPlayerReconnected"), self)
    ListenToGameEvent("entity_killed", Dynamic_Wrap(CHoldoutGameMode, "OnEntityKilled"), self)
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(CHoldoutGameMode, "OnGameRulesStateChange"), self)
    ListenToGameEvent("dota_item_picked_up", Dynamic_Wrap(CHoldoutGameMode, "OnItemPickUp"), self)
    ListenToGameEvent("dota_player_gained_level", Dynamic_Wrap(CHoldoutGameMode, "OnHeroLevelUp"), self)
    ListenToGameEvent("dota_player_learned_ability", Dynamic_Wrap(CHoldoutGameMode, "OnHeroLearnAbility"), self)
    ListenToGameEvent("dota_item_purchased", Dynamic_Wrap(CHoldoutGameMode, "OnItemPurchased"), self)
    ListenToGameEvent("dota_player_pick_hero", Dynamic_Wrap(CHoldoutGameMode, "OnPlayerPickHero"), self)
    --监听玩家打字
    ListenToGameEvent("player_chat", Dynamic_Wrap(CHoldoutGameMode, "OnPlayerSay"), self)

    --读取spell shop UI的kv内容
    self.HeroesKV = LoadKeyValues("scripts/kv/spell_shop_ui_herolist.txt")
    self.AbilitiesKV = LoadKeyValues("scripts/kv/spell_shop_ui_abilities.txt")
    self.AbilitiesCostKV = LoadKeyValues("scripts/kv/spell_shop_ui_abilities_cost.txt")
    --读取NPC配置文件的细节
    self.vNpcDetailKV = LoadKeyValues("scripts/npc/npc_units_custom.txt")

    GameRules:GetGameModeEntity():SetDamageFilter(Dynamic_Wrap(CHoldoutGameMode, "DamageFilter"), self)
    GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CHoldoutGameMode, "OrderFilter"), self)
    GameRules:GetGameModeEntity():SetModifyGoldFilter(Dynamic_Wrap(CHoldoutGameMode, "ModifyGoldFilter"), self)
    GameRules:GetGameModeEntity():SetModifierGainedFilter(Dynamic_Wrap(CHoldoutGameMode, "ModifierGainedFilter"), self)

    GameRules:GetGameModeEntity():SetLoseGoldOnDeath(false) --死亡不扣除金钱
    GameRules:GetGameModeEntity():SetContextThink("globalthink0", function() return self:OnThink() end, 1)

    -- 玩家可买物品最大数目，不限制
    SendToServerConsole("dota_max_physical_items_purchase_limit 9999")
    --self._vHeroList={}
    self:CreateNetTablesSettings()
    self:HeroListRefill()
end


-- Read and assign configurable keyvalues if applicable
function CHoldoutGameMode:_ReadGameConfiguration()
    local kv = LoadKeyValues("scripts/maps/" .. GetMapName() .. ".txt")
    kv = kv or {} -- Handle the case where there is not keyvalues file

    self._bAlwaysShowPlayerGold = kv.AlwaysShowPlayerGold or false
    self._bRestoreHPAfterRound = kv.RestoreHPAfterRound or false
    self._bRestoreMPAfterRound = kv.RestoreMPAfterRound or false

    self._bUseReactiveDifficulty = kv.UseReactiveDifficulty or false
    if testMode then
        self._flPrepTimeBetweenRounds = 2
    else
        self._flPrepTimeBetweenRounds = tonumber(kv.PrepTimeBetweenRounds or 0)
    end
    self._flItemExpireTime = tonumber(kv.ItemExpireTime or 10)

    self:_ReadRandomSpawnsConfiguration(kv["RandomSpawns"], kv["RandomSpawnsBig"])
    self:_ReadLootItemDropsConfiguration(kv["ItemDrops"])
    self:_ReadRoundConfigurations(kv)
end


-- Verify spawners if random is set
function CHoldoutGameMode:ChooseRandomSpawnInfo()
    if #self._vRandomSpawnsList == 0 then
        error("Attempt to choose a random spawn, but no random spawns are specified in the data.")
        return nil
    end
    return self._vRandomSpawnsList[RandomInt(1, #self._vRandomSpawnsList)]
end

-- 为体型大的单位设置的刷新点
function CHoldoutGameMode:ChooseRandomSpawnInfoForBigGuy()
    if #self._vRandomSpawnsListBig == 0 then
        error("Attempt to choose a random spawn for big, but no random spawns are specified in the data.")
        return nil
    end
    return self._vRandomSpawnsList[RandomInt(1, #self._vRandomSpawnsListBig)]
end



-- Verify valid spawns are defined and build a table with them from the keyvalues file
function CHoldoutGameMode:_ReadRandomSpawnsConfiguration(kvSpawns, kvSpawnsBig)
    self._vRandomSpawnsList = {}
    if type(kvSpawns) ~= "table" then
        return
    end
    for _, sp in pairs(kvSpawns) do
        table.insert(self._vRandomSpawnsList, {
            szSpawnerName = sp.SpawnerName or "",
            szFirstWaypoint = sp.Waypoint or ""
        })
    end

    self._vRandomSpawnsListBig = {}
    if type(kvSpawnsBig) ~= "table" then
        return
    end
    for _, sp in pairs(kvSpawnsBig) do
        table.insert(self._vRandomSpawnsListBig, {
            szSpawnerName = sp.SpawnerName or "",
            szFirstWaypoint = sp.Waypoint or ""
        })
    end
end




function CHoldoutGameMode:OnHeroLevelUp(keys)

    local player = PlayerInstanceFromIndex(keys.player)
    local hero = player:GetAssignedHero()
    local level = hero:GetLevel()
    local _playerId = hero:GetPlayerID()
    if keys.level == level then
        if hero:HasAbility("arc_warden_tempest_double") then
            local ability = hero:FindAbilityByName("arc_warden_tempest_double")
            local octarine_adjust = 1
            if hero:HasItemInInventory("item_octarine_core") then
                octarine_adjust = 0.75
            end
            local cooldown = ability:GetCooldown(ability:GetLevel() - 1) * octarine_adjust
        --[[		if  ability:GetCooldownTimeRemaining()>cooldown*0.9 then  --如果风暴双雄刚刚释放完毕 不扣除
			CustomGameEventManager:Send_ServerToPlayer(player,"UpdateAbilityList", {heroName=false,playerId=_playerId})
			return
		end
		]]
        end
        --7.0以后不给技能点 需要补回来
        if keys.level == 17 or keys.level == 19 or keys.level == 21 or keys.level == 22 or keys.level == 23 or keys.level == 24 then --7.0以后不给技能点
            local p = hero:GetAbilityPoints()
            hero:SetAbilityPoints(p + 1)
        end
        
        if keys.level == 30  then --7.23 30级倒扣8个技能点 需要补回来
            local p = hero:GetAbilityPoints()
            hero:SetAbilityPoints(p + 8)
        end

        -- 如果英雄的等级不是2的倍数，那么这个等级就不给技能点
        local _, l = math.modf((level - 1) / 2)
        if l ~= 0 then
            local p = hero:GetAbilityPoints()
            hero:SetAbilityPoints(p - 1)
        else
            --2的倍数 升级信使
            if hero.hCourier then
                hero.hCourier:SetBaseMoveSpeed(hero.hCourier:GetBaseMoveSpeed()+10)
            end
        end
    end
    CustomGameEventManager:Send_ServerToPlayer(player, "UpdateAbilityList", { heroName = false, playerId = _playerId })
end

--学习技能后刷新UI面板
function CHoldoutGameMode:OnHeroLearnAbility(keys)

    local player = PlayerInstanceFromIndex(keys.player)
    local hero = player:GetAssignedHero()
    local level = hero:GetLevel()
    local playerId = hero:GetPlayerID()
    local abilityname = keys.abilityname

    if mapTalentModifier[abilityname] then
        AddModifierHelper(hero, "modifier_" .. abilityname)
        -- hero:AddNewModifier(hero, nil, "modifier_" .. abilityname, {})
    end

    CustomGameEventManager:Send_ServerToPlayer(player, "UpdateAbilityList", { heroName = false, playerId = playerId })
end




function CHoldoutGameMode:OnItemPurchased(keys)
    --DeepPrint(keys)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.PlayerID), "UpdatePlayerAbilityList", { playerId = keys.PlayerID })
end



function CHoldoutGameMode:OnPlayerSay(keys)

    local player = PlayerInstanceFromIndex(keys.userid)
    local hero = player:GetAssignedHero()
    local nPlayerID = hero:GetPlayerID()
    local steamID = PlayerResource:GetSteamAccountID(nPlayerID)
    local text = string.trim(string.lower(keys.text))
    if string.match(text, "@") ~= nil then  --如果为邮件
        Patreon:GetPatrons(text, steamID, nPlayerID)
    end
    if string.match(text, "%w%w%w%w%-%w%w%w%w%-%w%w%w%w") ~= nil then  --如果为淘宝Code
        Taobao:RegisterVip(text, steamID, nPlayerID)
    end
    if string.match(text, "^%-[r|R][o|O][u|U][n|N][d|D]%d+") ~= nil and GameRules:IsCheatMode() then  --如果为跳关码
        local round = string.match(text, "%d+")
        print("round" .. round)
        self:TestRound(round, nil)
    end
    if string.match(text, "^%-[s|S][a|A][v|V][e|E][t|T][e|E][s|S][t|T]") ~= nil then  --存档测试开后门
        CustomGameEventManager:Send_ServerToPlayer(player, "SaveTestBackDoor", { playerId = nPlayerID })
    end
    --添加测试物品
    if hero and string.find(text,"item_") == 1  and  GameRules:IsCheatMode() then
       hero:AddItemByName(text)
    end
end

function CHoldoutGameMode:ModifyGoldFilter(keys)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(keys.player_id_const), "UpdatePlayerAbilityList", { playerId = keys.player_id_const })
    return true
end


function CHoldoutGameMode:OnPlayerPickHero(keys)

    local hero = EntIndexToHScript(keys.heroindex)
    local playerId = keys.player
    PlayerResource:SetBuybackGoldLimitTime(playerId, 0)

    if IsValidEntity(hero) then
        for i = 1, 20 do
            local ability = hero:GetAbilityByIndex(i - 1)
            if ability then
                --print("Abilities Report: "..hero:GetUnitName().."ability["..i.."] is "..ability:GetAbilityName())
                if string.find(ability:GetAbilityName(), "tws_ability_empty_") then
                    hero:RemoveAbility(ability:GetAbilityName())
                end
            else
                --print("Abilities Report: "..hero:GetUnitName().."ability["..i.."] is empty")
            end
        end
    end
end



-- If random drops are defined read in that data
function CHoldoutGameMode:_ReadLootItemDropsConfiguration(kvLootDrops)
    self._vLootItemDropsList = {}
    if type(kvLootDrops) ~= "table" then
        return
    end
    for _, lootItem in pairs(kvLootDrops) do
        table.insert(self._vLootItemDropsList, {
            szItemName = lootItem.Item or "",
            nChance = tonumber(lootItem.Chance or 0)
        })
    end
end


-- Set number of rounds without requiring index in text file
function CHoldoutGameMode:_ReadRoundConfigurations(kv)
    self._vRounds = {} --二维队列
    local roundIndex = 1

    while roundIndex == 1 or (roundIndex > 1 and self._vRounds[roundIndex - 1]) do  --如果至少有一个分支
        local brachIndex = 1
        while true do
            local szRoundName = string.format("Round%d-%d", roundIndex, brachIndex)
            local kvRoundData = kv[szRoundName]
            if kvRoundData == nil then
                print("Rounds" .. roundIndex .. "BrachIndex" .. brachIndex .. " is Empty")
                break
            end
            local roundObj = CHoldoutGameRound()
            roundObj:ReadConfiguration(kvRoundData, self, roundIndex)
            if self._vRounds[roundIndex] == nil then
                table.insert(self._vRounds, {}) --二维队列增加
            end
            table.insert(self._vRounds[roundIndex], roundObj)  --压入二维队列
            brachIndex = brachIndex + 1 --查看下一个分支
        end
        roundIndex = roundIndex + 1
    end
end


-- When game state changes set state in script
function CHoldoutGameMode:OnGameRulesStateChange()
    local nNewState = GameRules:State_Get()
    if nNewState == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
        --for i=1,5 do
        --Rank:GetRankDataFromServer(i) --从服务器获取天梯数据
        --end
        --服务器压力过大转为逐页加载  初始化的时候只默认加载第五页数据
        Rank:GetRankDataFromServer(5) --从服务器获取天梯数据
    elseif nNewState == DOTA_GAMERULES_STATE_HERO_SELECTION then
        PrecacheUnitByNameAsync('npc_precache_always', function() end)
        ShowGenericPopup("#holdout_instructions_title", "#holdout_instructions_body", "", "", DOTA_SHOWGENERICPOPUP_TINT_SCREEN)
        self:GetVipDataFromServer() --从服务器读取vip数据
    elseif nNewState == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        -- 为没选英雄的玩家随机选择英雄
        for i = 0, PlayerResource:GetPlayerCount() - 1 do
            if PlayerResource:IsValidPlayer(i) and not PlayerResource:HasSelectedHero(i) and PlayerResource:GetConnectionState(i) == DOTA_CONNECTION_STATE_CONNECTED then
                PlayerResource:GetPlayer(i):MakeRandomHeroSelection()
                PlayerResource:SetCanRepick(i, false)
            end
        end
    elseif nNewState == DOTA_GAMERULES_STATE_PRE_GAME then
        self.nTimeCost = -15 --计时器时间初始设置 负十五秒，正式开始计时
        Timers:CreateTimer({
            endTime = 7,
            callback = function()
                --为玩家创建信使
                Courier:CreateCourierForPlayers()
                --初始化VIP奖励
                InitVipReward()
            end
        })
    elseif nNewState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        self.flProgressTime = GameRules:GetGameTime()
        CustomGameEventManager:Send_ServerToAllClients("UpdateCmHud", {})

        --如果本局已经读盘 难度选择不影响
        if not GameRules:GetGameModeEntity().CHoldoutGameMode.bLoadFlag then
            self:SetBaseDifficulty()
        end
        --self.nTimeCost=0 --计时器时间清空，正式开始计时
    end
end



function CHoldoutGameMode:GetVipDataFromServer()  --从服务器读取vip数据
    local steamIDs
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        local steamID = PlayerResource:GetSteamAccountID(nPlayerID)
        if steamID ~= 0 and steamID ~= "0" then
            self.vipMap[steamID] = {}
            self.vipMap[steamID].level = 0
            self.vipMap[steamID].validDateUTC = ""
            self.steamIdMap[steamID] = nPlayerID
            if steamIDs == nil then
                steamIDs = steamID
            else
                steamIDs = steamIDs .. "," .. steamID
            end
        end
    end
    --print("***********"..steamIDs)
    Vip:GetVipDataFromServer(steamIDs) --从服务器获取这些玩家哪个是vip
end


-- Evaluate the state of the game
function CHoldoutGameMode:OnThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        if self.map_difficulty == nil then  --难度未定，不能开始
            if GameRules:GetGameTime() > self.flProgressTime + self.nTrialSetTime then
                self:SetTrialMapDifficulty()
            end
        else
            self:AddHeroDifficultyModifier()
            --如果第一关未开始
            if not self.bGameStarted then
                if self.map_difficulty <= 2 then
                    self.last_live = self.last_live + 1
                    if self.map_difficulty == 1 then
                        self.last_live = self.last_live + 1
                    end
                end
                -- 第一关选择分支
                self:PlayerSelectBranch()
                self.bGameStarted = true
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
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
            if PlayerResource:HasSelectedHero(nPlayerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                if hero then
                    if not hero:IsAlive() then
                        local vLocation = hero:GetOrigin()
                        hero:RespawnHero(false, false)
                        FindClearSpaceForUnit(hero, vLocation, true)
                    end
                    --重置买活时间与惩罚
                    --PlayerResource:SetBuybackCooldownTime( nPlayerID, 0 )
                    hero.heal_absorb = nil
                    PlayerResource:SetBuybackGoldLimitTime(nPlayerID, 0)
                    PlayerResource:ResetBuybackCostTime(nPlayerID)
                    PlayerResource:SetCustomBuybackCooldown(nPlayerID, 0)
                    hero:RemoveModifierByName("modifier_fire_twin_debuff")
                    hero:RemoveModifierByName("modifier_dark_twin_debuff")
                    hero:RemoveModifierByName("modifier_charge_dot")
                    hero:RemoveModifierByName("modifier_suffocating_bubble")
                    hero:RemoveModifierByName("modifier_overflow_show")
                    hero:RemoveModifierByName("modifier_silence_permenant")
                    hero:RemoveModifierByName("modifier_affixes_falling_rock")
                    hero:RemoveModifierByName("modifier_overflow_stack")
                    hero:RemoveModifierByName("modifier_zombie_explode_debuff")
                    hero:RemoveModifierByName("modifier_random_exp_bonus")
                    hero:RemoveModifierByName("modifier_affixes_dilation")
                    hero:RemoveModifierByName("modifier_affixes_silver")
                    hero:RemoveModifierByName("modifier_affixes_fragile")
                    hero:SetHealth(hero:GetMaxHealth())
                    hero:SetMana(hero:GetMaxMana())
                end
            end
        end
    end
    --[[ 7.23 信使复活速度足够快， 会造成信使重复活 废弃此代码 
    local couriersNumber = PlayerResource:GetNumCouriersForTeam(DOTA_TEAM_GOODGUYS)
    if couriersNumber > 0 then
        for i = 1, couriersNumber do
            local courier = PlayerResource:GetNthCourierForTeam(i - 1, DOTA_TEAM_GOODGUYS)
            print(courier:GetUnitName())
            if courier and not courier:IsAlive() then
                courier:RespawnUnit()
            end
        end
    end
    ]]
end


function CHoldoutGameMode:_GrantMulberry()  --给予桑葚
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
            if PlayerResource:HasSelectedHero(nPlayerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                if hero then
                    AddItemByName(hero, "item_mulberry")
                    if self.map_difficulty == 1 then
                        local modifier = hero:FindModifierByName("modifier_item_mulberry")
                        local stack_count = 0
                        if modifier then
                            stack_count = modifier:GetStackCount()
                        else
                            modifier = hero:AddNewModifier(hero, CreateItem("item_mulberry", hero, hero), "modifier_item_mulberry", {})
                        end
                        modifier:SetStackCount(stack_count + 1)
                    end
                    local steamID = PlayerResource:GetSteamAccountID(nPlayerID)
                    local vipMap = GameRules:GetGameModeEntity().CHoldoutGameMode.vipMap
                    if vipMap[tonumber(steamID)].level > 1 then  --VIP给俩
                        AddItemByName(hero, "item_mulberry")
                    end
                end
            end
        end
    end
end


function CHoldoutGameMode:_CheckForDefeat()  --无影拳CD的特殊修正  --测试模式补充技能点
    if GameRules:State_Get() ~= DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        return
    end

    local bAllPlayersDead = true
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
            if PlayerResource:HasSelectedHero(nPlayerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                if hero and hero:IsAlive() then
                    if hero:HasModifier("modifier_ember_spirit_sleight_of_fist_caster_invulnerability") then --无敌buff期间不走冷却
                        local modifier = hero:FindModifierByName("modifier_ember_spirit_sleight_of_fist_caster_invulnerability")
                        local ability = modifier:GetAbility()
                        local octarine_adjust = 1
                        if hero:HasItemInInventory("item_octarine_core") then
                            octarine_adjust = 0.75
                        end
                        ability:StartCooldown(ability:GetCooldown(ability:GetLevel() - 1) * octarine_adjust)
                    end
                    if testMode and hero:GetAbilityPoints() < 50 then --测试模式保持50点技能点
                        hero:SetAbilityPoints(50)
                    end
                    --local vModifier_table=hero:FindAllModifiers()
                    --for k,v in pairs(vModifier_table) do
                    --print("Effect Name"..v:GetName().."")
                    --end
                    --PrintTable(vModifier_table,nil,nil)
                    bAllPlayersDead = false
                    self.loseflag = 0
                end
            end
        end
    end

    if bAllPlayersDead and self._currentRound ~= nil then
        self.loseflag = self.loseflag + 1
    end
    if self.loseflag > 6 then
        self.last_live = self.last_live - 1
        table.insert(vFailedRound, self._nRoundNumber .. '_' .. self._nBranchIndex) --记录下折在第几关了
        if self.last_live == 0 then
            if self.map_difficulty >= 3 and not GameRules:IsCheatMode() and not self.bLoadFlag then --读盘的游戏不能上天梯
                --if true then
                Rank:RecordGame(self._nRoundNumber - 1, DOTA_TEAM_GOODGUYS) --储存并结束游戏
                return
            else
                GameRules:MakeTeamLose(DOTA_TEAM_GOODGUYS)
                return
            end
        elseif self.last_live < 0 then
            return
        else
            Notifications:BottomToAll({ text = "#round_fail", duration = 3, style = { color = "Fuchsia" } })
            Notifications:BottomToAll({ text = tostring(self.last_live), duration = 3, style = { color = "Red" }, continue = true })
            Notifications:BottomToAll({ text = "#chance_left", duration = 3, style = { color = "Fuchsia" }, continue = true })
            if self._currentRound then
                self._currentRound.achievement_flag = false
                self._currentRound:End()
                Detail:InsertPlayerStatusSnapshot(false)
            end
            self._currentRound = nil
            self:_RefreshPlayers()
            self:_GrantMulberry() --给予桑葚
            self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
        end
    end
end




function CHoldoutGameMode:_ThinkPrepTime()
    if GameRules:GetGameTime() >= self._flPrepTimeEnd then
        self._flPrepTimeEnd = nil
        if self._precacheFlag then
            QuestSystem:DelQuest("PrepTime")
            self._precacheFlag = nil  --预载入标识
        end
        if self._nRoundNumber > #self._vRounds then
            if self.map_difficulty >= 3 and not GameRules:IsCheatMode() and not self.bLoadFlag then
                Rank:RecordGame(self._nRoundNumber - 1, DOTA_TEAM_BADGUYS) --储存游戏成绩
                return false
            else
                GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS)
                return false
            end
        end
        print("self._nBranchIndex" .. self._nBranchIndex)
        self._currentRound = self._vRounds[self._nRoundNumber][self._nBranchIndex]
        self._currentRound:Begin()
        return
    end

    if not self._precacheFlag then
        QuestSystem:CreateQuest("PrepTime", "#tws_quest_prep_time", self._flPrepTimeBetweenRounds, self._flPrepTimeBetweenRounds, nil, self._nRoundNumber)
        print("self._nRoundNumber" .. self._nRoundNumber)
        print("self._nBranchIndex" .. self._nBranchIndex)
        self._vRounds[self._nRoundNumber][self._nBranchIndex]:Precache()
        self._precacheFlag = true
    end
    QuestSystem:RefreshQuest("PrepTime", math.ceil(self._flPrepTimeBetweenRounds - self._flPrepTimeEnd + GameRules:GetGameTime()), self._flPrepTimeBetweenRounds, self._nRoundNumber)

end


function CHoldoutGameMode:_ThinkLootExpiry()
    if self._flItemExpireTime <= 0 then
        return
    end

    local flCutoffTime = GameRules:GetGameTime() - self._flItemExpireTime

    for _, item in pairs(Entities:FindAllByClassname("dota_item_drop")) do
        local containedItem = item:GetContainedItem()
        if containedItem then
            if containedItem:GetAbilityName() == "item_bag_of_gold_tws" or containedItem:GetAbilityName() == "item_rock" or item.Holdout_IsLootDrop then
                self:_ProcessItemForLootExpiry(item, flCutoffTime)
            end
        else
            self:_ProcessItemForLootExpiry(item, flCutoffTime)
        end
    end
end


function CHoldoutGameMode:_ProcessItemForLootExpiry(item, flCutoffTime)
    if item:IsNull() then
        return false
    end
    if item:GetCreationTime() >= flCutoffTime then
        return true
    end

    local containedItem = item:GetContainedItem()

    if containedItem and containedItem:GetAbilityName() == "item_bag_of_gold_tws" then
        if self._currentRound and self._currentRound.OnGoldBagExpired then
            self._currentRound:OnGoldBagExpired()
        end
    end
    local nFXIndex = ParticleManager:CreateParticle("particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, item)
    ParticleManager:SetParticleControl(nFXIndex, 0, item:GetOrigin())
    ParticleManager:SetParticleControl(nFXIndex, 1, Vector(35, 35, 25))
    ParticleManager:ReleaseParticleIndex(nFXIndex)
    local inventoryItem = item:GetContainedItem()
    if inventoryItem then
        --print("Removing item "..inventoryItem:GetName())
        --有时候移除特殊物品会导致游戏崩溃（各类飞鞋）
        --print("inventoryItem:GetClassname()"..inventoryItem:GetClassname())
        UTIL_Remove(inventoryItem)
    end
    UTIL_Remove(item)
    return false
end

function CHoldoutGameMode:OnNPCSpawned(event)

    local spawnedUnit = EntIndexToHScript(event.entindex)

    if spawnedUnit == nil or spawnedUnit:IsNull() or spawnedUnit:GetClassname() == "npc_dota_thinker" or spawnedUnit:IsPhantom() then
        return
    end

    if spawnedUnit:IsRealHero() then
        if spawnedUnit.modifier_to_be_added ~= nil then
            for _, fn in pairs(spawnedUnit.modifier_to_be_added) do
                fn()
            end
            spawnedUnit.modifier_to_be_added = {}
        end
    elseif spawnedUnit:IsSummoned() then
        spawnedUnit:AddNewModifier(nil, nil, "modifier_invulnerable", { duration = 0.35 })
    end

    Timers:CreateTimer({
        endTime = 0.3,
        callback = function()
            if not spawnedUnit:IsNull() then

                if (spawnedUnit:IsSummoned() or spawnedUnit:IsNeutralUnitType()) and not spawnedUnit:IsRealHero() then
                    local owner = spawnedUnit:GetOwner()
                    if owner ~= nil then
                        --local playerid=spawnedUnit:GetOwner():GetPlayerID()
                        local crownLevel = 0
                        if owner:HasModifier("modifier_crown_6_datadriven") then
                            crownLevel = 6
                        elseif owner:HasModifier("modifier_crown_5_datadriven") then
                            crownLevel = 5
                        elseif owner:HasModifier("modifier_crown_4_datadriven") then
                            crownLevel = 4
                        elseif owner:HasModifier("modifier_crown_3_datadriven") then
                            crownLevel = 3
                        elseif owner:HasModifier("modifier_crown_2_datadriven") then
                            crownLevel = 2
                        elseif owner:HasModifier("modifier_crown_1_datadriven") then
                            crownLevel = 1
                        end

                        if crownLevel > 0 then
                            spawnedUnit.owner = owner
                            owner.crownLevel = crownLevel
                            if not spawnedUnit:HasAbility("crown_summoned_buff") then
                                spawnedUnit:AddAbility("crown_summoned_buff")
                                local ability = spawnedUnit:FindAbilityByName("crown_summoned_buff")
                                ability:SetLevel(crownLevel)
                            end
                        else
                            if spawnedUnit:HasAbility("crown_summoned_buff") then
                                spawnedUnit:RemoveAbility("crown_summoned_buff")
                            end
                        end
                    end

                elseif spawnedUnit:GetTeam() == DOTA_TEAM_GOODGUYS then
                    if string.sub(spawnedUnit:GetUnitName(), 1, 14) == "npc_dota_tiny_" then
                        return
                    end
                    local counterAbility = spawnedUnit:FindAbilityByName("damage_counter")
                    if counterAbility == nil then
                        counterAbility = spawnedUnit:AddAbility("damage_counter")  --伤害计数器
                    end
                    if counterAbility:GetLevel() == 0 then
                        counterAbility:SetLevel(1)

                        if self.map_difficulty and self.map_difficulty == 1 then
                            counterAbility:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_map_easy_show", {})
                        elseif self.map_difficulty and self.map_difficulty == 3 then
                            counterAbility:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_map_hard_show", {})
                        elseif self.map_difficulty and self.map_difficulty > 3 then
                            counterAbility:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_map_endless_stack", {})
                            spawnedUnit:SetModifierStackCount("modifier_map_endless_stack", ability, self.map_difficulty - 3)
                        end
                    end
                else
                    if not spawnedUnit:HasAbility("monster_endless_stack_show") then
                        spawnedUnit:AddAbility("monster_endless_stack_show")
                    end
                    spawnedUnit.damageMultiple = self.flDDadjust   --这个值可能变的

                    local ability = spawnedUnit:FindAbilityByName("monster_endless_stack_show")
                    local maxHealth = spawnedUnit:GetMaxHealth()
                    local newMaxHealth = maxHealth * self.flDHPadjust
                    local healthRegen = math.max(newMaxHealth * 0.0012, spawnedUnit:GetBaseHealthRegen())  --1.2%%的基础恢复
                    if newMaxHealth < 1 then --避免出现0血单位
                        newMaxHealth = 1
                    end
                    spawnedUnit:SetBaseHealthRegen(healthRegen)
                    spawnedUnit:SetBaseMaxHealth(newMaxHealth)

                    if self.map_difficulty == 1 then
                        ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_monster_debuff", {})
                    elseif self.map_difficulty == 3 then
                        ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_monster_buff", {})
                    elseif self.map_difficulty > 3 then
                        ability:ApplyDataDrivenModifier(spawnedUnit, spawnedUnit, "modifier_monster_map_endless_stack", {})
                        spawnedUnit:SetModifierStackCount("modifier_monster_map_endless_stack", ability, self.map_difficulty - 3)
                    end

                    spawnedUnit:AddNewModifier(spawnedUnit, ability, "modifier_increase_total_damage_lua", {})

                    if self.map_difficulty > 5 and self._currentRound ~= nil and spawnedUnit:GetUnitName() ~= "npc_dota_creature_affixes_laser_turret" then
                        if self._currentRound.vAffixes.necrotic then
                            spawnedUnit:AddAbility("affixes_ability_necrotic")
                            spawnedUnit:FindAbilityByName("affixes_ability_necrotic"):SetLevel(1)
                        end
                        if self._currentRound.vAffixes.raging then
                            spawnedUnit:AddAbility("affixes_ability_raging")
                            spawnedUnit:FindAbilityByName("affixes_ability_raging"):SetLevel(1)
                        end
                        if self._currentRound.vAffixes.fortify then
                            spawnedUnit:AddAbility("affixes_ability_fortify")
                            spawnedUnit:FindAbilityByName("affixes_ability_fortify"):SetLevel(1)
                        end
                        if self._currentRound.vAffixes.bolstering then
                            spawnedUnit:AddAbility("affixes_ability_bolstering")
                            spawnedUnit:FindAbilityByName("affixes_ability_bolstering"):SetLevel(1)
                        end
                        if self._currentRound.vAffixes.sanguine then
                            spawnedUnit:AddAbility("affixes_ability_sanguine")
                            spawnedUnit:FindAbilityByName("affixes_ability_sanguine"):SetLevel(1)
                        end
                        if self._currentRound.vAffixes.spike then
                            spawnedUnit:AddAbility("affixes_ability_spike")
                            spawnedUnit:FindAbilityByName("affixes_ability_spike"):SetLevel(1)
                        end
                    end
                end
            end
        end
    })
end


--[[function CHoldoutGameMode:OnNPCReplaced( event )
	local spawnedUnit = EntIndexToHScript( event.new_entindex )
	print("new npc"..spawnedUnit:GetUnitName())
end
]]
--[[function CHoldoutGameMode:OnUseAbility(event)
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
    for i = 0, playercount - 1 do
        local line = {}
        line.playerid = i
        line.total_damage = self._currentRound._vPlayerStats[i].nTotalDamage
        line.total_heal = self._currentRound._vPlayerStats[i].nTotalHeal
        line.gold_collect = self._currentRound._vPlayerStats[i].nGoldBagsCollected
        table.insert(data, line)
    end
    table.sort(data, function(a, b) return a.total_damage > b.total_damage end)
    data.playercount = playercount
    data.timecost = GameRules:GetGameTime() - self._currentRound.Begin_Time

    self._currentRound:End()
    Detail:InsertPlayerStatusSnapshot(true)
    if self._currentRound.achievement_flag then
        data.acheivement_flag = 1
    else
        data.acheivement_flag = 0
    end
    CustomGameEventManager:Send_ServerToAllClients("game_end", data)

    self._currentRound = nil
    self:_RefreshPlayers()
    --关卡进入下一关
    self._nRoundNumber = self._nRoundNumber + 1

    while (self.vRoundSkip[self._nRoundNumber] ~= nil and self._nRoundNumber < 20) do  --如果符合跳关条件

        if self.vRoundSkip[self._nRoundNumber] == 1 then
            self.nGoldToCompensate = self.nGoldToCompensate + self._vRounds[self._nRoundNumber][1]._nExpectedGold * 0.15 --累计金币 此处使用第一个分支的金钱奖励
            self.nExpToCompensate = self.nExpToCompensate + self._vRounds[self._nRoundNumber][1]._nFixedXP * 0.15 --累计经验
        elseif self.vRoundSkip[self._nRoundNumber] == 2 then
            self.nGoldToCompensate = self.nGoldToCompensate + self._vRounds[self._nRoundNumber][1]._nExpectedGold * 0.25 --累计金币
            self.nExpToCompensate = self.nExpToCompensate + self._vRounds[self._nRoundNumber][1]._nFixedXP * 0.25 --累计经验
        end
        self._nRoundNumber = self._nRoundNumber + 1  --跳过

    end

    local playernumberbonus = 0.5
    local playerNumber = 0
    -- 统计人数
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
            if PlayerResource:HasSelectedHero(nPlayerID) then
                playernumberbonus = playernumberbonus + 0.5
                playerNumber = playerNumber + 1
            end
        end
    end

    if playerNumber > 0 then

        --开始金币补偿
        if self.nGoldToCompensate > 0 then
            --补偿的时候 显示VIP特效
            ShowVIPParticle() --util里面定义
            local goldCompensatePerWave = self.nGoldToCompensate * playernumberbonus / 30 / playerNumber  --分30波补偿
            local expCompensatePerWave = self.nExpToCompensate * playernumberbonus / 30 / playerNumber
            self.nGoldToCompensate = 0
            self.nExpToCompensate = 0
            local nWave = 1
            Timers:CreateTimer(5, function()
                for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
                    if PlayerResource:IsValidPlayer(nPlayerID) then
                        if PlayerResource:HasSelectedHero(nPlayerID) then
                            local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                            local steamID = PlayerResource:GetSteamAccountID(nPlayerID)
                            if self.vipMap[steamID].level >= 2 then
                                SendOverheadEventMessage(hero, OVERHEAD_ALERT_GOLD, hero, goldCompensatePerWave * 3, nil)  --三倍补偿
                                PlayerResource:ModifyGold(nPlayerID, goldCompensatePerWave * 3, true, DOTA_ModifyGold_Unspecified)
                                hero:AddExperience(expCompensatePerWave * 3, 0, false, false)
                            else
                                SendOverheadEventMessage(hero, OVERHEAD_ALERT_GOLD, hero, goldCompensatePerWave, nil)
                                PlayerResource:ModifyGold(nPlayerID, goldCompensatePerWave, true, DOTA_ModifyGold_Unspecified)
                                hero:AddExperience(expCompensatePerWave, 0, false, false)
                            end
                        end
                    end
                end
                if nWave == 30 then  --30波补偿
                    return nil
                else
                    nWave = nWave + 1
                    return 0.3
                end
            end)
        end
    end
    if self._nRoundNumber > (#self._vRounds - 1) then
        if self.map_difficulty >= 3 and not GameRules:IsCheatMode() and not self.bLoadFlag then
            Rank:RecordGame(self._nRoundNumber - 1, DOTA_TEAM_BADGUYS) --储存游戏
            return false
        else
            GameRules:MakeTeamLose(DOTA_TEAM_BADGUYS) --作弊或者难度不对，直接结束比赛
            return false
        end
    else
        --如果有分支，弹出分选择窗口
        if #self._vRounds[self._nRoundNumber] > 1 then
            self:PlayerSelectBranch() --玩家选择分支
        else   --如果没有多余分支，下一关分支编号为1
            GameRules:GetGameModeEntity().CHoldoutGameMode.bRandomRound = false --本轮非随机
            self._nBranchIndex = 1
            self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
        end

    end
end


function CHoldoutGameMode:PlayerSelectBranch()
    local shortTitles = {}
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer(nPlayerID) then
            self.vSelectionData[nPlayerID] = 0 --默认选择分支0
        end
    end

    for i = 1, #self._vRounds[self._nRoundNumber] do
        --将配置文件中的标题传进参数
        table.insert(shortTitles, self._vRounds[self._nRoundNumber][i]._shortTitle)
    end
    --第一个参数是分支数目，第二个参数是分支的Short Title
    CustomGameEventManager:Send_ServerToAllClients("ShowBranchSelection", { branchNumber = #self._vRounds[self._nRoundNumber], shortTitles = shortTitles })

    --将玩家默认选择随机分支
    CustomGameEventManager:Send_ServerToAllClients("SelectBranchReturn", { selectionData = self.vSelectionData })

    Timers:CreateTimer({  --设置定时器 xx秒以后 下一轮准备时间开始
        endTime = 10,
        callback = function()
            --确定分支选择
            SettleBranchIndex()
            --开始下一关的准备倒计时
            GameRules:GetGameModeEntity().CHoldoutGameMode._flPrepTimeEnd = GameRules:GetGameTime() + GameRules:GetGameModeEntity().CHoldoutGameMode._flPrepTimeBetweenRounds
        end
    })
end



function SettleBranchIndex() --确定分支选择

    local branchMap = {}  --key是分支编号 --value是分支选择人数

    local vRounds = GameRules:GetGameModeEntity().CHoldoutGameMode._vRounds
    local roundNumber = GameRules:GetGameModeEntity().CHoldoutGameMode._nRoundNumber
    local vSelectionData = GameRules:GetGameModeEntity().CHoldoutGameMode.vSelectionData

    local branchIndex = 0 --下一关的分支号码,默认随机

    -- 分支选择人数，初始化为0
    for i = 0, #vRounds[roundNumber] do
        branchMap[i] = 0
    end

    -- 统计各个分支得票数
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer(nPlayerID) then
            local branchIndex = tonumber(vSelectionData[nPlayerID])
            branchMap[branchIndex] = branchMap[branchIndex] + 1 --人数
        end
    end
    branchMap[0] = 0 -- 随机者的投票无权重

    -- 找到最多得票数分支
    for i = 0, #vRounds[roundNumber] do
        if branchMap[i] > branchMap[branchIndex] then
            branchIndex = i
        end
    end

    if branchIndex ~= 0 then
        local allBranchesSame = true
        for i = 1, #vRounds[roundNumber] do
            if branchMap[i] ~= branchMap[branchIndex] then
                allBranchesSame = false
            end
        end
        if allBranchesSame then
            branchIndex = 0
        end
    end

    if branchIndex == 0 then  --如果随机
        branchIndex = RandomInt(1, #vRounds[roundNumber])  --随机出一个分支号码
        for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:IsValidPlayer(nPlayerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                local ability = hero:FindAbilityByName("damage_counter")
                ability:ApplyDataDrivenModifier(hero, hero, "modifier_random_exp_bonus", {})
            end
        end
        vRounds[roundNumber][branchIndex]._nItemDropNum = vRounds[roundNumber][branchIndex]._nItemDropNum * fRandomRoundBonus --随机关卡调整物品掉率
        vRounds[roundNumber][branchIndex]._nFixedXP = vRounds[roundNumber][branchIndex]._nFixedXP * fRandomRoundBonus --随机关卡调整经验

        GameRules:GetGameModeEntity().CHoldoutGameMode.bRandomRound = true --本轮随机
    else
        GameRules:GetGameModeEntity().CHoldoutGameMode.bRandomRound = false
    end

    GameRules:GetGameModeEntity().CHoldoutGameMode._nBranchIndex = branchIndex --记录下一关的分支编号
end


function CHoldoutGameMode:OnPlayerReconnected(event)

    Timers:CreateTimer({
        endTime = 8,
        callback = function()
            -- 需要为重连的玩家更新技能列表，因为玩家也许吃了无限法球
            local player = PlayerResource:GetPlayer(event.PlayerID)
            local hero = player:GetAssignedHero()

            local maxSlotNumber = 6

            if hero:HasModifier("modifier_extra_slot_9_consume") then
                maxSlotNumber = 9
            elseif hero:HasModifier("modifier_extra_slot_8_consume") then
                maxSlotNumber = 8
            elseif hero:HasModifier("modifier_extra_slot_7_consume") then
                maxSlotNumber = 7
            end

            CustomGameEventManager:Send_ServerToPlayer(player, "UpdateAbilityList", { heroName = false, playerId = event.PlayerID, maxSlotNumber = maxSlotNumber })
        end
    })
end


function CHoldoutGameMode:OnEntityKilled(event)
    local killedUnit = EntIndexToHScript(event.entindex_killed)

    if killedUnit == nil then
        return
    end
    if self._currentRound and killedUnit:GetTeam() == DOTA_TEAM_BADGUYS and killedUnit.removedByMech == nil then
        if self._currentRound._alias == "warlock" and killedUnit:GetUnitName() == "npc_dota_warlock_boss_2" or
        self._currentRound._alias == "tree" and killedUnit:GetUnitName() == "npc_dota_boss_enchantress" or
        self._currentRound._alias == "tinker" and killedUnit:GetUnitName() == "npc_dota_boss_tinker" or
        self._currentRound._alias == "invoker" and killedUnit:GetUnitName() == "npc_dota_creature_boss_invoker" or
        self._currentRound._alias == "rubick" and killedUnit:GetUnitName() == "npc_dota_boss_rubick" then
            if self._currentRound.vAffixes.teeming == false or self.firstBossDead == true then
                self:RoundEnd()
            else
                self.firstBossDead = self._currentRound.vAffixes.teeming
            end
        end
    end

    if killedUnit:IsRealHero() then
        killedUnit.heal_absorb = nil
        killedUnit:RemoveModifierByName("modifier_overflow_stack") --死亡移除溢出效果
        if self._currentRound and (self._currentRound._alias == "skeleton" or self._currentRound._alias == "bandit") and self._currentRound.achievement_flag then
            local playername = PlayerResource:GetPlayerName(killedUnit:GetPlayerOwnerID())
            local hero_name = PlayerResource:GetSelectedHeroName(killedUnit:GetPlayerOwnerID())
            Notifications:BottomToAll({ hero = hero_name, duration = 4 })
            Notifications:BottomToAll({ text = playername .. " ", duration = 4, continue = true })
            Notifications:BottomToAll({ text = "#round1_acheivement_fail_note", duration = 4, style = { color = "Orange" }, continue = true })
            QuestSystem:RefreshAchQuest("Achievement", 0, 1)
            self._currentRound.achievement_flag = false
        end
        local newItem = CreateItem("item_tombstone", killedUnit, killedUnit)
        newItem:SetPurchaseTime(0)
        newItem:SetPurchaser(killedUnit)
        local tombstone = SpawnEntityFromTableSynchronous("dota_item_tombstone_drop", {})
        tombstone:SetContainedItem(newItem)
        tombstone:SetAngles(0, RandomFloat(0, 360), 0)
        FindClearSpaceForUnit(tombstone, killedUnit:GetAbsOrigin(), true)
    end
end


function CHoldoutGameMode:CheckForLootItemDrop(killedUnit)
    for _, itemDropInfo in pairs(self._vLootItemDropsList) do
        if RollPercentage(itemDropInfo.nChance) then
            local newItem = CreateItem(itemDropInfo.szItemName, nil, nil)
            newItem:SetPurchaseTime(0)
            if newItem:IsPermanent() and newItem:GetShareability() == ITEM_FULLY_SHAREABLE then
                item:SetStacksWithOtherOwners(true)
            end
            local drop = CreateItemOnPositionSync(killedUnit:GetAbsOrigin(), newItem)
            drop.Holdout_IsLootDrop = true
        end
    end
end


function CHoldoutGameMode:OnItemPickUp(event, level)
    --PrintTable(event)
    local item = EntIndexToHScript(event.ItemEntityIndex)
    local owner
    if event.UnitEntityIndex then
        local unit = EntIndexToHScript(event.UnitEntityIndex)
        if unit:GetUnitName() == "npc_dota_courier" then --如果是信使捡起的物品，则物品属于操作信使的人
            if item:GetPurchaser() == nil then
                local playerId = unit.nControlledPickPlayerId
                local hero = PlayerResource:GetSelectedHeroEntity(playerId)
                owner = hero
                --print(hero:GetUnitName())
                item:SetPurchaser(hero)
            end
        end
    end


    if event.HeroEntityIndex then
        owner = EntIndexToHScript(event.HeroEntityIndex)
    end
    if owner then
        if string.sub(event.itemname, 1, 20) == "item_treasure_chest_" then
            LootController:SpecialItemAdd(owner, tonumber(string.sub(event.itemname, 21, string.len(event.itemname))), #self._vRounds)
            UTIL_Remove(item)
        else
            --解决7.23掉落物品 无法出售的问题
            if event.itemname ~= "item_tombstone" then
               item:SetPurchaser(owner)
            end
        end
    end
end


-- Custom game specific console command "holdout_test_round"
function CHoldoutGameMode:_TestRoundConsoleCommand(cmdName, roundNumber, delay)
    self:TestRound(roundNumber, delay)
end




function CHoldoutGameMode:TestRound(roundNumber, delay)

    local nRoundToTest = tonumber(roundNumber)
    if nRoundToTest <= 0 or nRoundToTest > #self._vRounds then
        return
    end

    self.bGameStarted = true

    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer(nPlayerID) then
            PlayerResource:ModifyGold(nPlayerID, 999999, true, DOTA_ModifyGold_Unspecified)
            PlayerResource:GetPlayer(nPlayerID):GetAssignedHero():SetAbilityPoints(50)
            PlayerResource:SetBuybackCooldownTime(nPlayerID, 0)
            PlayerResource:SetBuybackGoldLimitTime(nPlayerID, 0)
            PlayerResource:ResetBuybackCostTime(nPlayerID)
        end
    end
    self:_RefreshPlayers()
    if self._currentRound then
        self._currentRound:End()
        self._currentRound = nil
    end
    for _, item in pairs(Entities:FindAllByClassname("dota_item_drop")) do
        local containedItem = item:GetContainedItem()
        if containedItem then
            UTIL_Remove(containedItem)
        end
        UTIL_Remove(item)
    end

    self._nRoundNumber = nRoundToTest


    if #self._vRounds[self._nRoundNumber] > 1 then
        local shortTitles = {}
        for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
            if PlayerResource:IsValidPlayer(nPlayerID) then
                self.vSelectionData[nPlayerID] = 0 --默认选择分支0
            end
        end

        for i = 1, #self._vRounds[self._nRoundNumber] do
            --将配置文件中的标题传进参数
            shortTitles[i] = self._vRounds[self._nRoundNumber][i]._shortTitle
        end
        --第一个参数是分支数目，第二个参数是分支的Short Title
        CustomGameEventManager:Send_ServerToAllClients("ShowBranchSelection", { branchNumber = #self._vRounds[self._nRoundNumber], shortTitles = shortTitles })

        --将玩家默认选择随机分支
        CustomGameEventManager:Send_ServerToAllClients("SelectBranchReturn", { selectionData = self.vSelectionData })

        Timers:CreateTimer({  --设置定时器 xx秒以后 下一轮准备时间开始
            endTime = 8,
            callback = function()
                SettleBranchIndex()
                --开始下一关的准备倒计时
                GameRules:GetGameModeEntity().CHoldoutGameMode._flPrepTimeEnd = GameRules:GetGameTime() + GameRules:GetGameModeEntity().CHoldoutGameMode._flPrepTimeBetweenRounds

            end
        })

    else
        self._nBranchIndex = 1
        if delay ~= nil then
            self._flPrepTimeEnd = GameRules:GetGameTime() + tonumber(delay)
        else
            self._flPrepTimeEnd = GameRules:GetGameTime() + self._flPrepTimeBetweenRounds
        end
    end

    self._precacheFlag = false

end


function CHoldoutGameMode:_StatusReportConsoleCommand(cmdName)
    print("*** Holdout Status Report ***")
    print(string.format("Current Round: %d", self._nRoundNumber))
    if self._currentRound then
        self._currentRound:StatusReport()
    end
    print("*** Holdout Status Report End *** ")
end



-- Custom game specific console command "list_modifiers"
function CHoldoutGameMode:_ListModifiers(cmdName)
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:IsValidPlayer(nPlayerID) then
            if PlayerResource:HasSelectedHero(nPlayerID) then
                local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
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
    for group, heroes in pairs(self.HeroesKV) do
        CustomNetTables:SetTableValue("heroes", group, heroes)
    end
    -- Abilities
    for heroName, abilityKV in pairs(self.AbilitiesKV) do
        CustomNetTables:SetTableValue("abilities", heroName, abilityKV)
    end
    for abilityName, abilityCost in pairs(self.AbilitiesCostKV) do
        CustomNetTables:SetTableValue("abilitiesCost", abilityName, { tonumber(abilityCost) })
    end
end


--选择分支,后台记录 报告全部前台
function CHoldoutGameMode:SelectBranch(keys)

    if type(keys.branch) == "string" then
        local player = PlayerResource:GetPlayer(keys.playerID)
        if player == nil then return end

        GameRules:GetGameModeEntity().CHoldoutGameMode.vSelectionData[keys.playerID] = keys.branch

        CustomGameEventManager:Send_ServerToAllClients("SelectBranchReturn", { selectionData = GameRules:GetGameModeEntity().CHoldoutGameMode.vSelectionData })
    end
end