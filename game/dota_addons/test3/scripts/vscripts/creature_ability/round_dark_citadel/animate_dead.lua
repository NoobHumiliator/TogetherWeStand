function AnimateDead( event )
	local caster = event.caster
	local ability = event.ability
	local team = event.caster:GetTeamNumber()
	local radius = ability:GetLevelSpecialValueFor( "radius", ability:GetLevel() - 1 )
	local duration = ability:GetLevelSpecialValueFor( "duration", ability:GetLevel() - 1 )
	local max_units_resurrected = ability:GetLevelSpecialValueFor( "max_units_resurrected", ability:GetLevel() - 1 )

	for i=1,max_units_resurrected do
			local caster_location=caster:GetAbsOrigin()
            local resurected_vector=Vector(caster_location.x+RandomInt(-radius, radius),caster_location.y+RandomInt(-radius, radius),0)
            resurected_vector.z= GetGroundHeight(resurected_vector,nil)
			local resurected = CreateUnitByName("npc_dota_creature_abomination", resurected_vector, true, nil, nil, team)
			-- Apply modifiers for the summon properties
			resurected:AddNewModifier(caster, ability, "modifier_kill", {duration = duration})
			ability:ApplyDataDrivenModifier(caster, resurected, "modifier_animate_dead", nil)

	end
	Notifications:BossAbilityDBM("death_knight_boss_animate_dead")
end
