
function LevelupBurst( keys )
	local caster = keys.caster
    local target = keys.target
    
	if not target:HasAbility("courier_burst") then  --如果没有技能，赋予技能
		target:AddAbility("courier_burst")
		target:FindAbilityByName("courier_burst"):SetLevel(1)
	else  --升级技能
		local abilityLevel = target:FindAbilityByName("courier_burst"):GetLevel()
		if abilityLevel<target:FindAbilityByName("courier_burst"):GetMaxLevel() then
			target:FindAbilityByName("courier_burst"):SetLevel(abilityLevel+1)
	    end
	end
	
end
