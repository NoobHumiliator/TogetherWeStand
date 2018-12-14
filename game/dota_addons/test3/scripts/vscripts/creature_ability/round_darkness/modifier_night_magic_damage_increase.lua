modifier_night_magic_damage_increase = class({})
--------------------------------------------------------------------------------
function modifier_night_magic_damage_increase:IsPurgable()			return false end
function modifier_night_magic_damage_increase:IsHidden()			return true end
--------------------------------------------------------------------------------
function modifier_night_magic_damage_increase:OnCreated( kv )
	self.magic_enhance_ptc_per_stack = self:GetAbility():GetSpecialValueFor( "magic_enhance_ptc_per_stack" )
end
--------------------------------------------------------------------------------

function modifier_night_magic_damage_increase:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_SPELL_AMPLIFY_PERCENTAGE
	}
	return funcs
end
--------------------------------------------------------------------------------

function modifier_night_magic_damage_increase:OnRefresh()
    if IsServer() then
      local ability=attacker:FindAbilityByName("night_creature_increase_damage")
      local stacks_number=attacker:GetModifierStackCount("modifier_night_damage_stack",ability)   	
	  self.spell_incease_pct = self.magic_enhance_ptc_per_stack * stacks_number
    end
end
--------------------------------------------------------------------------------

function modifier_night_magic_damage_increase:GetModifierSpellAmplify_Percentage( params )
	return self.spell_incease_pct
end
--------------------------------------------------------------------------------