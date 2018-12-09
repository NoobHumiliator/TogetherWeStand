modifier_doom_bringer_devour_datadriven = class({})
--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_datadriven:IsPurgable()			return false end
function modifier_doom_bringer_devour_datadriven:IsDebuff()			return true end
function modifier_doom_bringer_devour_datadriven:IsHidden()			return false end

--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_datadriven:GetAttributes()
  return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
function modifier_doom_bringer_devour_datadriven:OnCreated( kv )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen" )
	self.bonus_gold = self:GetAbility():GetSpecialValueFor( "bonus_gold" )
end
--------------------------------------------------------------------------------

function modifier_doom_bringer_devour_datadriven:OnRefresh( kv )
	self.regen = self:GetAbility():GetSpecialValueFor( "regen" )
	self.bonus_gold = self:GetAbility():GetSpecialValueFor( "bonus_gold" )
end
--------------------------------------------------------------------------------

function modifier_doom_bringer_devour_datadriven:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end
--------------------------------------------------------------------------------

function modifier_doom_bringer_devour_datadriven:GetModifierConstantHealthRegen( params )
	return self.regen
end
--------------------------------------------------------------------------------

function modifier_doom_bringer_devour_datadriven:OnDestroy( params )

	if IsServer() then
		local caster = self:GetAbility():GetCaster()
		if caster and caster:IsAlive() then
			SendOverheadEventMessage( caster, OVERHEAD_ALERT_GOLD, caster, self.bonus_gold, nil )
			self:GetAbility():GetCaster():ModifyGold(self.bonus_gold,true,0)
		end
	end

end