--[[
	Author: kritth
	Date: 7.1.2015.
	Put modifier to override animation on cast
]]
function rearm_start( keys )
	local caster = keys.caster
	local ability = keys.ability
	local abilityLevel = ability:GetLevel()
	caster:RemoveModifierByName("modifier_slark_shadow_dance")
    caster:RemoveModifierByName("modifier_abaddon_borrowed_time")
	ability:ApplyDataDrivenModifier( caster, caster, "modifier_rearm_level_" .. abilityLevel .. "_datadriven", {} )
end

--[[
	Author: kritth
	Date: 7.1.2015.
	Refresh cooldown
]]
function rearm_refresh_cooldown( keys )
	local caster = keys.caster
	
	-- Reset cooldown for abilities that is not rearm
	local ability_exempt_table = {}
    ability_exempt_table["phoenix_supernova"]=true
    ability_exempt_table["skeleton_king_reincarnation"]=true
    ability_exempt_table["undying_tombstone"]=true
    ability_exempt_table["self_undying_tombstone"]=true
    ability_exempt_table["arc_warden_tempest_double"]=true
	for i = 0, caster:GetAbilityCount() - 1 do
		local ability = caster:GetAbilityByIndex( i )
		if ability and ability ~= keys.ability and not ability_exempt_table[ability:GetAbilityName()]then
			ability:EndCooldown()
		end
	end
	
	-- Put item exemption in here
	local exempt_table = {}
	exempt_table["item_hand_of_midas"]=true
    exempt_table["item_refresher"]=true
    exempt_table["item_black_king_bar"]=true
    exempt_table["item_arcane_boots"]=true
    exempt_table["item_arcane_boots"]=true
    exempt_table["item_guardian_greaves"]=true
	exempt_table["item_skysong_blade"]=true
	exempt_table["item_fallen_sword"]=true
	exempt_table["item_arcane_boots2"]=true

	-- Reset cooldown for items
	for i = 0, 5 do
		local item = caster:GetItemInSlot( i )
		if item and not exempt_table[item:GetAbilityName()] then
			item:EndCooldown()
		end
	end
end
