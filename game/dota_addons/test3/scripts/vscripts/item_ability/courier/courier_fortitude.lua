
function LevelupFortitude( keys )
	local caster = keys.caster
    local target = keys.target


	if not target:HasAbility("courier_fortitude_datadriven") then  --如果没有技能，赋予技能
		target:AddAbility("courier_fortitude_datadriven")
		target:FindAbilityByName("courier_fortitude_datadriven"):SetLevel(1)
	else  --升级技能
		local abilityLevel = target:FindAbilityByName("courier_fortitude_datadriven"):GetLevel()
		if abilityLevel<target:FindAbilityByName("courier_fortitude_datadriven"):GetMaxLevel() then
			target:FindAbilityByName("courier_fortitude_datadriven"):SetLevel(abilityLevel+1)
	    end
	end
	ReportHeroAbilities(target)
end
