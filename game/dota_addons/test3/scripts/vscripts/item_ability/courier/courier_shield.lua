require( "util" )
--[[
function LevelupShield( keys )
	local caster = keys.caster
    local target = keys.target
    

    if alreadyCached['npc_precache_courier_shield_datadriven']==true then
    else				
      alreadyCached['npc_precache_courier_shield_datadriven'] = true
      PrecacheUnitByNameAsync('npc_precache_courier_shield_datadriven', function() end)
    end
    
    RemoveRedundantAbility(target)

    if target:HasAbility("courier_shield") then
       target:FindAbilityByName("courier_shield"):SetHidden(true)
    end

   if not target:HasAbility("courier_shield_datadriven") then  --如果没有技能，赋予技能
  		target:AddAbility("courier_shield_datadriven")
  		target:FindAbilityByName("courier_shield_datadriven"):SetLevel(2)
   else  --升级技能
  		local abilityLevel = target:FindAbilityByName("courier_shield_datadriven"):GetLevel()
  		if abilityLevel<target:FindAbilityByName("courier_shield_datadriven"):GetMaxLevel() then
  			target:FindAbilityByName("courier_shield_datadriven"):SetLevel(abilityLevel+1)
  	    end
   end
	 
    --target:SwapAbilities("courier_shield_datadriven","damage_counter",true,true)
    ReportHeroAbilities(target)

end
]]

function LevelupShield( keys )
    local caster = keys.caster
    local target = keys.target
    
    --移除掉多余技能
    RemoveRedundantCourierAbility(target)


    if not target:HasAbility("courier_shield") then  --如果没有技能，赋予技能
      target:AddAbility("courier_shield")
      target:FindAbilityByName("courier_shield"):SetLevel(1)
    else  --升级技能
      local abilityLevel = target:FindAbilityByName("courier_shield"):GetLevel()
      if abilityLevel<target:FindAbilityByName("courier_shield"):GetMaxLevel() then
        target:FindAbilityByName("courier_shield"):SetLevel(abilityLevel+1)
      end
    end

    ReportHeroAbilities(target)
    
end

