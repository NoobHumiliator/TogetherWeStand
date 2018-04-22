
function LevelupSellItems( keys )
	local caster = keys.caster
    local target = keys.target


  RemoveRedundantCourierAbility(target)
    
	if not target:HasAbility("courier_sell_items_datadriven") then  --如果没有技能，赋予技能
		target:AddAbility("courier_sell_items_datadriven")
		target:FindAbilityByName("courier_sell_items_datadriven"):SetLevel(1)
	else  --升级技能
		local abilityLevel = target:FindAbilityByName("courier_sell_items_datadriven"):GetLevel()
		if abilityLevel<target:FindAbilityByName("courier_sell_items_datadriven"):GetMaxLevel() then
			target:FindAbilityByName("courier_sell_items_datadriven"):SetLevel(abilityLevel+1)
	    end
	end
  
end

