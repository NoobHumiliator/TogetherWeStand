
function LevelupHook( keys )
	local caster = keys.caster
  local target = keys.target
    

  if alreadyCached['npc_precache_courier_hook_datadriven']==true then
  else				
      alreadyCached['npc_precache_courier_hook_datadriven'] = true
      PrecacheUnitByNameAsync('npc_precache_courier_hook_datadriven', function() end)
  end
  
  RemoveRedundantCourierAbility(target)

	if not target:HasAbility("courier_hook_datadriven") then  --如果没有技能，赋予技能
		target:AddAbility("courier_hook_datadriven")
		target:FindAbilityByName("courier_hook_datadriven"):SetLevel(1)
	else  --升级技能
		local abilityLevel = target:FindAbilityByName("courier_hook_datadriven"):GetLevel()
		  if abilityLevel<target:FindAbilityByName("courier_hook_datadriven"):GetMaxLevel() then
			  target:FindAbilityByName("courier_hook_datadriven"):SetLevel(abilityLevel+1)
	    end
	end
  AddRedundantCourierAbility(target)	
end

