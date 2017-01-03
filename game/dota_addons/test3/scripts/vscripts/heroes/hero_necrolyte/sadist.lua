function ApplySadist( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_modifier = keys.stack_modifier
	local stack_count = caster:GetModifierStackCount(stack_modifier, ability)

	ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {})

	caster:SetModifierStackCount(stack_modifier, ability, stack_count + 1)

end


function RemoveSadist( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_modifier = keys.stack_modifier
	local stack_count = caster:GetModifierStackCount(stack_modifier, ability)

	if stack_count <= 1 then
		caster:RemoveModifierByName(stack_modifier)
	else
		caster:SetModifierStackCount(stack_modifier, ability, stack_count - 1)
	end
end


function ApplySadistHero( keys )
	local caster = keys.caster
	local ability = keys.ability
	local modifier = keys.modifier
	local hero_multiplier = ability:GetLevelSpecialValueFor("hero_multiplier", (ability:GetLevel() - 1))

	-- Starts from 2 since OnKill already applied 1 stack
	for i = 2, hero_multiplier do
		ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
	end
end