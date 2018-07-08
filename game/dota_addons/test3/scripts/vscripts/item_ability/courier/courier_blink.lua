
function LevelupBlink( keys )
	local caster = keys.caster
    local target = keys.target
    
    if alreadyCached['npc_precache_courier_blink_datadriven']==true then
    else				
      alreadyCached['npc_precache_courier_blink_datadriven'] = true
      PrecacheUnitByNameAsync('npc_precache_courier_blink_datadriven', function() end)
    end
   
  --移除掉多余技能
  RemoveRedundantCourierAbility(target)


	if not target:HasAbility("courier_blink_datadriven") then  --如果没有技能，赋予技能
		target:AddAbility("courier_blink_datadriven")
		target:FindAbilityByName("courier_blink_datadriven"):SetLevel(1)
		target:FindAbilityByName("courier_blink_datadriven"):SetAbilityIndex(1)
	else  --升级技能
		local abilityLevel = target:FindAbilityByName("courier_blink_datadriven"):GetLevel()
		if abilityLevel<target:FindAbilityByName("courier_blink_datadriven"):GetMaxLevel() then
			target:FindAbilityByName("courier_blink_datadriven"):SetLevel(abilityLevel+1)
	    end
	end

  AddRedundantCourierAbility(target)	
end
