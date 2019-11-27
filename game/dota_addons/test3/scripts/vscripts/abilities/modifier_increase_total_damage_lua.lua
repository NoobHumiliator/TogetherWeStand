modifier_increase_total_damage_lua = class({})


function modifier_increase_total_damage_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end


function modifier_increase_total_damage_lua:IsHidden()
	return true
end


function modifier_increase_total_damage_lua:OnCreated( kv )
    if IsServer() then
		local caster = self:GetParent()
	    local percentage = 0
        self:StartIntervalThink( 1.0 )
	    if caster~=nil and caster.damageMultiple~=nil then
	    	percentage = (caster.damageMultiple-1)*100
	    end
		self.percentage=percentage
    end
end

function modifier_increase_total_damage_lua:OnRefresh( kv )

end


function modifier_increase_total_damage_lua:OnIntervalThink()   --每秒调节加成

	if IsServer() then
		local caster = self:GetParent()
		if caster~=nil and caster.damageMultiple~=nil then
	    	self.percentage = (caster.damageMultiple-1)*100
	    end
	end

end



function modifier_increase_total_damage_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end



function modifier_increase_total_damage_lua:GetModifierTotalDamageOutgoing_Percentage()

	return  self.percentage

end
