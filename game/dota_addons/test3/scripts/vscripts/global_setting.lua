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


--体型表
vHullSizeTable={DOTA_HULL_SIZE_SMALL=8,DOTA_HULL_SIZE_REGULAR=16,DOTA_HULL_SIZE_SIEGE=16,
                DOTA_HULL_SIZE_HERO=24,DOTA_HULL_SIZE_HUGE=80,DOTA_HULL_SIZE_BUILDING=81,
                DOTA_HULL_SIZE_FILLER=96,DOTA_HULL_SIZE_BARRACKS=144,DOTA_HULL_SIZE_TOWER=144}
