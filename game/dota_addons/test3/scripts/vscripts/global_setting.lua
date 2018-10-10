--[[
 Global Variety
]]

world_left_x=-3072
world_left_y=-3072
world_right_x=3712
world_right_y=3712

hardLevelItemDropBonus = {1.45,1.15,0.90}
for i=1,200 do
	table.insert(hardLevelItemDropBonus,0.85)
end

vipSteamIDTable={88765185,171757477,86815341,284814746,171588248,212313158}



--随机关卡奖励倍数

fRandomRoundBonus=1.4


--体型表
vHullSizeTable={DOTA_HULL_SIZE_SMALL=8,DOTA_HULL_SIZE_REGULAR=16,DOTA_HULL_SIZE_SIEGE=16,
                DOTA_HULL_SIZE_HERO=24,DOTA_HULL_SIZE_HUGE=80,DOTA_HULL_SIZE_BUILDING=81,
                DOTA_HULL_SIZE_FILLER=96,DOTA_HULL_SIZE_BARRACKS=144,DOTA_HULL_SIZE_TOWER=144}

--怪物非正常死亡时 应删除的技能
vToRemoveAbilityOnRemoveMap={
	npc_dota_boss_rattletrap="rattletrap_gold_bag_fountain",
	npc_dota_boss_blue_dragon="blue_dragon_gold_bag_fountain",
	npc_dota_boss_mag="mag_gold_bag_fountain",
	npc_dota_boss_sky="sky_gold_bag_fountain",
	npc_dota_boss_enchantress="enchantress_gold_bag_fountain",
	npc_dota_warlock_boss_2="warlock_gold_bag_fountain",
	npc_dota_splitter_b="creature_split_b",
	npc_dota_splitter_a="creature_split_a",
	npc_dota_boss_tidehunter="tidehunter_gold_bag_fountain",
	npc_dota_boss_lion="lion_gold_bag_fountain",
	npc_dota_boss_tinker="tinker_gold_bag_fountain",
	npc_dota_creature_gold_zombie="gold_zombie_straight_wave",
	npc_dota_creature_red_zombie="red_zombie_lean_wave",
	npc_dota_water_1="water_die",
	npc_dota_water_2="water_die",
	npc_dota_water_3="water_die",
	npc_dota_water_3="water_die",
	npc_dota_water_1s="water_die",
	npc_dota_water_2s="water_die",
	npc_dota_water_3s="water_die"
}
