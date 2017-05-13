function SetHealth( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability

	local bonus_health = ability:GetLevelSpecialValueFor( "bonus_health", ( ability:GetLevel() - 1 ) )
  
  if caster.courierBaseMaxHp==nil then
     caster.courierBaseMaxHp=caster:GetMaxHealth()
  end
  print("caster.courierBaseMaxHp+bonus_health"..(caster.courierBaseMaxHp+bonus_health) )
  caster:SetMaxHealth(caster.courierBaseMaxHp+bonus_health)

end

