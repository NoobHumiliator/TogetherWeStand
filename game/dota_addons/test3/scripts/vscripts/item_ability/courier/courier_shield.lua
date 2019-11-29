require( "util" )

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

