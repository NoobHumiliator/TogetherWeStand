modifier_explode_expansion_thinker_aura_effect = class({})

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura_effect:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura_effect:OnCreated( kv )
	if self:GetParent() and self:GetParent().IsAlive and self:GetParent():IsAlive() then
	  self.damage_per_tick = self:GetParent():GetMaxHealth()*0.004  
    end
	self:StartIntervalThink(0.1)
end

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura_effect:OnRefresh( kv )
	
	if self:GetParent() and self:GetParent():IsAlive() then
	  self.damage_per_tick = self:GetParent():GetMaxHealth()*0.004   
    end

end

--------------------------------------------------------------------------------
function modifier_explode_expansion_thinker_aura_effect:OnIntervalThink()
	if IsServer() then
		local damageTable = 
        {
            victim=self:GetParent(),
            attacker=self:GetCaster(),
            damage_type=DAMAGE_TYPE_PURE,
            damage=self.damage_per_tick,
            ability = self:GetAbility()
        }
        
        ApplyDamage(damageTable)
        self:GetParent():ReduceMana(50)

        EmitSoundOn( "Hero_Alchemist.AcidSpray.Damage", self:GetParent() )
	end
end
--------------------------------------------------------------------------------
function modifier_explode_expansion_thinker_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_HEALING,
		MODIFIER_PROPERTY_TOTALDAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end
--------------------------------------------------------------------------------
function modifier_explode_expansion_thinker_aura_effect:CheckState()
	local state = {
		--[MODIFIER_STATE_SILENCED] = true,
		--[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end
------------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura_effect:GetDisableHealing( params )
	return 1
end

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura_effect:GetModifierTotalDamageOutgoing_Percentage()

	return  -200

end
