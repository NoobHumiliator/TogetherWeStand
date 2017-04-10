--[[Author: YOLOSPAGHETTI
	Date: February 17, 2016
	Applies the damage to the target]]
function ApplyDPS(keys)
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability
	if caster~=nil and ability~=nil then
		local health_percent = ability:GetLevelSpecialValueFor("damage_percent", ability:GetLevel() -1)/100
		local health = target:GetMaxHealth()
		ApplyDamage({victim = target, attacker = caster, damage = health * health_percent, damage_type = ability:GetAbilityDamageType()})
	end
end
