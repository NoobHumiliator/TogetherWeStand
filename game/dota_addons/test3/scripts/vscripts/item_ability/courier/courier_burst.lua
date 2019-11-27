
function LevelupBurst( keys )
	local caster = keys.caster
    local target = keys.target

    --移除掉这个多余技能
    if target:HasAbility("courier_go_to_secretshop") then
       target:RemoveAbility("courier_go_to_secretshop")
    end


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




