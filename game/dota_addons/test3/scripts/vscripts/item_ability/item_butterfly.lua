



LinkLuaModifier( "modifier_movespeed_cap", "item_ability/modifier/modifier_movespeed_cap", LUA_MODIFIER_MOTION_NONE )

function Butterfly(keys)
  keys.caster:EmitSound("DOTA_Item.Butterfly")
  local ability_level = keys.ability:GetLevel() - 1
  local duration = keys.ability:GetLevelSpecialValueFor("duration", ability_level)

  keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, "modifier_item_butterfly_datadriven_movespeed", nil)
  print("duration"..duration)
  keys.caster:AddNewModifier(caster, keys.ability, "modifier_movespeed_cap", { duration = duration })
end