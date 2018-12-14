require( "util" )

function TakeDamage(event)
    local damage = event.Damage
   	local caster = event.caster
	local ability = event.ability
    local attacker = event.attacker
    
    --反伤不受怪物伤害增幅影响
    if attacker.damageMultiple~=nil then
        damage=damage/attacker.damageMultiple
    end
    
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = attacker
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = damage*(ability:GetSpecialValueFor( "damage_reflection_pct" )/100)

	damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
	ApplyDamage(damage_table)
end