modifier_unholy_cd_reduction_lua = class({})

--------------------------------------------------------------------------------
function modifier_unholy_cd_reduction_lua:IsHidden()
	return true
end
-------------------------------------------------------------------------------

function modifier_unholy_cd_reduction_lua:OnCreated( kv )
	local ability = self:GetAbility()
	local stack_modifier = "modifier_unholy_datadriven"
	local cool_down_reduce_per_stack=self:GetAbility():GetSpecialValueFor( "cool_down_reduce" )
	local caster=self:GetCaster()
	self.cool_down_reduce = cool_down_reduce_per_stack*caster:GetModifierStackCount(stack_modifier, ability)
end

--------------------------------------------------------------------------------

function modifier_unholy_cd_reduction_lua:OnRefresh( kv )
	local ability = self:GetAbility()
	local stack_modifier = "modifier_unholy_stack_datadriven"
	local cool_down_reduce_per_stack=self:GetAbility():GetSpecialValueFor( "cool_down_reduce" )
	local caster=self:GetCaster()
	local cool_down_reduce= cool_down_reduce_per_stack*caster:GetModifierStackCount(stack_modifier, ability)
	if cool_down_reduce>80 then
		cool_down_reduce=80
	end
	self.cool_down_reduce = cool_down_reduce
end

--------------------------------------------------------------------------------

function modifier_unholy_cd_reduction_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_COOLDOWN_PERCENTAGE
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_unholy_cd_reduction_lua:GetModifierPercentageCooldown( params )
	return self.cool_down_reduce
end
