
function ApplyWaterBuff( keys )
	local caster = keys.caster
	local ability = keys.ability
	local stack_modifier = keys.stack_modifier
	local stack_count = caster:GetModifierStackCount(stack_modifier, ability)
    --print("modier_____11"..stack_modifier)
    --print("stack_count"..stack_count)
	ability:ApplyDataDrivenModifier(caster, caster, stack_modifier, {})
	caster:SetModifierStackCount(stack_modifier, ability, stack_count + 1)

end
