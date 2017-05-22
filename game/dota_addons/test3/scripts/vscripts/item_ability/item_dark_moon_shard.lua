function DarkMoonConsume(keys)
  local  caster = keys.caster
  local  playerId = caster:GetPlayerOwnerID()
  local  ability = keys.ability
  AddStacks(ability,caster,caster,"modifier_item_dark_moon_shard",1,true)
  local maxSpeed = GameRules:GetGameModeEntity():GetMaximumAttackSpeed()
  maxSpeed=maxSpeed*100
  GameRules:GetGameModeEntity():SetMaximumAttackSpeed(maxSpeed+100)   --提升全地图所有单位100最大攻速
end




function AddStacks(ability, caster, unit, modifier, stack_amount, refresh)
  if unit:HasModifier(modifier) then
    if refresh then
      ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
    end
    unit:SetModifierStackCount(modifier, ability, unit:GetModifierStackCount(modifier, nil) + stack_amount)
  else
    ability:ApplyDataDrivenModifier(caster, unit, modifier, {})
    unit:SetModifierStackCount(modifier, ability, stack_amount)
  end
end
