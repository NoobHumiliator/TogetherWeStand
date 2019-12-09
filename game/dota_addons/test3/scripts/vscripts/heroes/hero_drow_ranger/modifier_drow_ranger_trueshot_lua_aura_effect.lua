
if modifier_drow_ranger_trueshot_lua_aura_effect == nil then modifier_drow_ranger_trueshot_lua_aura_effect = class({}) end
function modifier_drow_ranger_trueshot_lua_aura_effect:IsHidden() return false end
function modifier_drow_ranger_trueshot_lua_aura_effect:IsDebuff() return false end
function modifier_drow_ranger_trueshot_lua_aura_effect:IsPurgable() return false end

function modifier_drow_ranger_trueshot_lua_aura_effect:GetStatusEffectName()  
	return "particles/units/heroes/hero_drow/drow_aura_buff.vpcf"
end


function modifier_drow_ranger_trueshot_lua_aura_effect:OnCreated(keys)
	self.trueshot_ranged_damage = self:GetAbility():GetSpecialValueFor("trueshot_ranged_damage")
end

function modifier_drow_ranger_trueshot_lua_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE,
	}
	return funcs
end



function modifier_drow_ranger_trueshot_lua_aura_effect:GetModifierPreAttack_BonusDamage( params )
	return self.trueshot_ranged_damage / 100 * self:GetAbility():GetCaster():GetAgility()
end

----------------------------------------