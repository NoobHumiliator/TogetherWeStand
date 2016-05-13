function DeathPact( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local target_health = event.target:GetHealth()
	local rate = ability:GetLevelSpecialValueFor( "conversion_rate" , ability:GetLevel() - 1 ) * 0.01

	caster:Heal( target_health * rate, caster)
	target:Kill(ability, caster)
end
