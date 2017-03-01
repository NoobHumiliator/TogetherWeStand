require("util")

modifier_increase_mana_cost_lua = class({})


function modifier_increase_mana_cost_lua:DeclareFunctions()
	local funcs = {
		--MODIFIER_EVENT_ON_MANA_GAINED,
		MODIFIER_PROPERTY_MANACOST_PERCENTAGE,
	}
	return funcs
end

function modifier_increase_mana_cost_lua:OnCreated( kv )
    if IsServer() then
	    --self:GetCaster():AddNewModifier(self:GetCaster(),self,"modifier_rune_arcane",{})
	    --print(self:GetCaster():FindModifierByName("modifier_rune_arcane"):GetClass())
	    if  self:GetCaster().sp==nil then
			self.percentageManacost=100
		else
			--print("Refresh ModifierPercentageManacost"..math.floor(self:GetCaster().sp*self:GetCaster():GetIntellect())+100)
			self.percentageManacost= math.floor(self:GetCaster().sp*self:GetCaster():GetIntellect())+100
		end
    end
end

function modifier_increase_mana_cost_lua:AllowIllusionDuplicate()
    return false 
end


--[[

function modifier_increase_mana_cost_lua:OnRefresh( kv )
	if  self:GetCaster().sp==nil then
		self.percentageManacost=100
	else
		--print("Refresh ModifierPercentageManacost"..math.floor(self:GetCaster().sp*self:GetCaster():GetIntellect())+100)
		self.percentageManacost= math.floor(self:GetCaster().sp*self:GetCaster():GetIntellect())+100
	end
end

--------------------------------------------------------------------------------

function modifier_increase_mana_cost_lua:OnManaGained( params )
	if IsServer() then
	    --print("params  gain"..params.gain)
	   -- DeepPrint( params )
	    if (not self:GetParent():IsIllusion()) then
			local rate= 1+self:GetParent().sp*self:GetParent():GetIntellect()/100  --法术增幅率
			--print("rate"..rate)
			--print("reduce mana"..params.gain* (1-1/rate))
			self:GetParent():ReduceMana( params.gain* (1-1/rate))
	    end
    end
end
]]
-----------------------------------------------------------------------------------
function modifier_increase_mana_cost_lua:GetModifierPercentageManacost()
	return -100
end
-----------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
function modifier_increase_mana_cost_lua:GetTexture()
	return "arcane_curse"
end



