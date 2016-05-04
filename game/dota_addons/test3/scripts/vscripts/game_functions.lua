function SpecialItemAdd( event, level )
	local item = EntIndexToHScript( event.ItemEntityIndex )
	local owner = EntIndexToHScript( event.HeroEntityIndex )
	local hero = owner:GetClassname()
	local ownerTeam = owner:GetTeamNumber()
	local tier_level=level
	local tier1 = 
	{
		"item_unholy"
	}
	local tier2 = 
	{
	   "item_fallen_sword"
	}
	local tier3 = 
	{
	   "item_skysong_blade"
	}
	local tier4 = 
	{
		"item_bloodsipper"
	}
	local tier5 = 
	{
		"item_skadi",
		"item_sange_and_yasha",
		"item_greater_crit",
		"item_sheepstick",
		"item_orchid",
		"item_heart",
		"item_mjollnir",
		"item_ethereal_blade",
		"item_radiance",
		"item_abyssal_blade",
		"item_butterfly",
		"item_monkey_king_bar",
		"item_satanic",
		"item_octarine_core",
		"item_silver_edge",
		"item_rapier"
	}
	local tier6 = 
	{
		"item_water_sword"
	}
	local tier7 = 
	{
		"item_skadi",
		"item_sange_and_yasha",
		"item_greater_crit",
		"item_sheepstick",
		"item_orchid",
		"item_heart",
		"item_mjollnir",
		"item_ethereal_blade",
		"item_radiance",
		"item_abyssal_blade",
		"item_butterfly",
		"item_monkey_king_bar",
		"item_satanic",
		"item_octarine_core",
		"item_silver_edge",
		"item_rapier"
	}
	local tier8 = 
	{
		"item_skadi",
		"item_sange_and_yasha",
		"item_greater_crit",
		"item_sheepstick",
		"item_orchid",
		"item_heart",
		"item_mjollnir",
		"item_ethereal_blade",
		"item_radiance",
		"item_abyssal_blade",
		"item_butterfly",
		"item_monkey_king_bar",
		"item_satanic",
		"item_octarine_core",
		"item_silver_edge",
		"item_rapier"
	}
	local tier9 = 
	{
		"item_skadi",
		"item_sange_and_yasha",
		"item_greater_crit",
		"item_sheepstick",
		"item_orchid",
		"item_heart",
		"item_mjollnir",
		"item_ethereal_blade",
		"item_radiance",
		"item_abyssal_blade",
		"item_butterfly",
		"item_monkey_king_bar",
		"item_satanic",
		"item_octarine_core",
		"item_silver_edge",
		"item_rapier"
	}
	local t1 = PickRandom( tier1)
	local t2 = PickRandom( tier2)
	local t3 = PickRandom( tier3)
	local t4 = PickRandom( tier4)
	local t5 = PickRandom( tier5)
	local t6 = PickRandom( tier6)
	local t7 = PickRandom( tier7)
	local t8 = PickRandom( tier8)
	local t9 = PickRandom( tier9)

	local spawnedItem = ""
	if tier_level==1 then
	   spawnedItem = PickRandom( tier1)
	 elseif tier_level==2 then
	   spawnedItem = PickRandom( tier2)
      elseif  tier_level==3 then
        spawnedItem = PickRandom( tier3)
        elseif  tier_level==4 then
        	 spawnedItem = PickRandom( tier4)
        	elseif  tier_level==5 then
        		spawnedItem = PickRandom( tier5)
        		 elseif  tier_level==6 then
        		 	spawnedItem = PickRandom( tier6)
        		 	 elseif  tier_level==7 then
        		 	   spawnedItem = PickRandom( tier7)
        		 	    elseif tier_level==8 then
        		 	    	    spawnedItem = PickRandom(tier8)
        		 	      elseif  tier_level==9 then
        		 	    	        spawnedItem = PickRandom(tier9)
    end
	-- add the item to the inventory and broadcast
	owner:AddItemByName( spawnedItem )
	local particle= ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf",PATTACH_ABSORIGIN_FOLLOW,owner)
    ParticleManager:ReleaseParticleIndex(particle)
	EmitGlobalSound("powerup_04")
end


function KillTiny()
    local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    for _,unit in pairs(targets) do
        if unit:GetUnitName()==("npc_dota_tiny_1") or unit:GetUnitName()==("npc_dota_tiny_2")  or unit:GetUnitName()==("npc_dota_tiny_3") or unit:GetUnitName()==("npc_dota_tiny_4") or unit:GetUnitName()==("npc_dota_tiny_5") then
            unit.die_in_peace=true
            unit:ForceKill(true)
        end
    end
end
