

function FierySoul( keys )
	local caster = keys.caster
	local ability = keys.ability
	local cast_ability = keys.event_ability
	local maxStack = ability:GetLevelSpecialValueFor("fiery_soul_max_stacks", (ability:GetLevel() - 1))
	local modifierCount = caster:GetModifierCount()
	local currentStack = 0
	local modifierBuffName = "modifier_fiery_soul_buff_datadriven"
	local modifierStackName = "modifier_fiery_soul_buff_stack_datadriven"
	local modifierName


   if cast_ability and cast_ability:GetManaCost( cast_ability:GetLevel() - 1 ) > 0 then
	 caster:RemoveModifierByName(modifierStackName) 
	 for i = 0, modifierCount do
		modifierName = caster:GetModifierNameByIndex(i)

		if modifierName == modifierBuffName then
			currentStack = currentStack + 1
		end
	 end
	 for i = 0, currentStack do
		caster:RemoveModifierByName(modifierBuffName)
	 end
	 ability:ApplyDataDrivenModifier(caster, caster, modifierStackName, {})
	 if currentStack >= maxStack then
		caster:SetModifierStackCount(modifierStackName, ability, maxStack)
		for i = 1, maxStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
		end
	  else
		currentStack = currentStack + 1
		caster:SetModifierStackCount(modifierStackName, ability, currentStack)
		for i = 1, currentStack do
			ability:ApplyDataDrivenModifier(caster, caster, modifierBuffName, {})
	 	end
	  end
   end
end