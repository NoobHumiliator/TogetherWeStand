function CHoldoutGameMode:ModifierGainedFilter(event)
  
  --PrintTable(event)
  if not event.entindex_parent_const then 
    return true
  end
  
  local target = EntIndexToHScript(event.entindex_parent_const)
  
  if target and target.GetUnitName and target:GetUnitName() then   --不受斩杀
      if target:HasModifier("modifier_faceless_undie") and event.name_const=="modifier_ice_blast" then
        return false
      end
  end
  
  return true

end