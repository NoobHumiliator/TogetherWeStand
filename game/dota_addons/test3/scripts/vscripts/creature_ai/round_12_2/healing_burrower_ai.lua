
--[[ units/ai/ai_healing_burrower.lua ]]

----------------------------------------------------------------------------------------------

function Spawn( entityKeyValues )
	if thisEntity == nil then
		return
	end

	hHealAbility = thisEntity:FindAbilityByName( "healing_burrower_suicide_heal" )

	thisEntity:SetContextThink( "HealingNyxThink", HealingNyxThink, 0.5 )
end

----------------------------------------------------------------------------------------------

function HealingNyxThink()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end

	if GameRules:IsGamePaused() == true then
		return 1
	end

	local hCreatures = Entities:FindAllByClassnameWithin( "npc_dota_creature", thisEntity:GetAbsOrigin(), 2000 )
	local hGuardians = {}
	for _, hCreature in pairs( hCreatures ) do
		if ( hCreature:GetUnitName() == "npc_dota_boss_sand_king" ) and hCreature:IsAlive() then
			return CastSuicideHeal( hCreature )
		end
	end

	return 0.1
end

----------------------------------------------------------------------------------------------

function CastSuicideHeal( hCreature )
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = hHealAbility:entindex(),
		TargetIndex = hCreature:entindex(),
	})
	return 1
end


