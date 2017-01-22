function TakeDamage( event )
	local caster=event.caster
    local ability = event.ability
	local damage = event.Damage 

	local allies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, caster:GetOrigin(), nil, nil, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    for _,ally in pairs(allies) do  --共享血量 共享伤害        
        if ally:HasAbility(ability:GetAbilityName()) then
	        local damage_table = {}
			damage_table.attacker = caster
			damage_table.victim = ally
			damage_table.damage_type = DAMAGE_TYPE_PURE
			damage_table.ability = ability
			damage_table.damage = damage
			damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
	        ApplyDamage(damage_table)
        end
	end 
end