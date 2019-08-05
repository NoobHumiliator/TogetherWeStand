function SellAllItems( keys )
	-- Variables
	local caster = keys.caster
	local ability = keys.ability
    caster.bSellInterrupted=nil --没有被打断

    local shopPosition=GetGroundPosition(Vector(2095.59,1048.89,128),caster)
    caster:MoveToPosition(shopPosition)
    Timers:CreateTimer(
    function()
       if caster.bSellInterrupted~=nil and caster.bSellInterrupted==true then --被打断
       	  return nil
       else
       	  --print((caster:GetAbsOrigin()-shopPosition):Length2D())
       	  if (caster:GetAbsOrigin()-shopPosition):Length2D()<500 then
	       	  	for i=0, 8, 1 do
					local current_item = caster:GetItemInSlot(i)
					if current_item ~= nil then
					   caster:SellItem(current_item)
					end
				end
				caster.bSellInterrupted=true
       	  end
       	  return 0.5
       end
    end)
end

