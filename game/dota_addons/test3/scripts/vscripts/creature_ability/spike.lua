require( "util" )

function ReflectDamage(event)

    PrintTable(event)
    local caster = event.caster
    local attacker = event.attacker
	local ability = event.ability
	local damage = event.Damage 
    print("damage"..damage)

    local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = attacker
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = damage
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE

    --PrintTable(damage_table)

	ApplyDamage(damage_table)

end