function SanguineDamage( keys )
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	local adjust=1.0
	if ability then
		if  caster and caster.damageMultiple~=nil then
			adjust=1/caster.damageMultiple
		end
		--print("adjust"..adjust)
		local damage_percent = ability:GetLevelSpecialValueFor( "damage_percent" , ability:GetLevel() - 1 )
		if target:GetTeam()==DOTA_TEAM_BADGUYS then
			local heal=target:GetMaxHealth()*damage_percent/100*adjust
			--print('heal'..heal)
			target:Heal(heal,caster)
		end
		if target:GetTeam()==DOTA_TEAM_GOODGUYS then
			local damage=target:GetMaxHealth()*damage_percent/100*adjust
			local damage_table = {}
		      damage_table.attacker = caster
		      damage_table.victim = target
		      damage_table.damage_type = DAMAGE_TYPE_PURE
		      damage_table.ability = ability
		      damage_table.damage = damage
		      damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
		      ApplyDamage(damage_table)
		end
    end
end