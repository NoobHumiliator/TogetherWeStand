function FallingRockDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local victims = FindUnitsInRadius( DOTA_TEAM_BADGUYS, target:GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for _,victim in pairs(victims) do
		local damage=victim:GetMaxHealth()*0.2
		local damage_table = {}
		damage_table.attacker = target
		damage_table.victim = victim
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.ability = ability
		damage_table.damage = damage
		damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
		ApplyDamage(damage_table)
	end

end


function FallingRockDot( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local victims = FindUnitsInRadius( DOTA_TEAM_BADGUYS, target:GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for _,victim in pairs(victims) do
		local damage=victim:GetMaxHealth()*0.01
		local damage_table = {}
		damage_table.attacker = target
		damage_table.victim = victim
		damage_table.damage_type = DAMAGE_TYPE_PURE
		damage_table.ability = ability
		damage_table.damage = damage
		damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
		ApplyDamage(damage_table)
	end

end