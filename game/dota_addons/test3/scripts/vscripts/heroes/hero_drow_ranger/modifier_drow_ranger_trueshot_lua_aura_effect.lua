
if modifier_drow_ranger_trueshot_lua_aura_effect == nil then modifier_item_guardian_greaves_lua_aura_effect = class({}) end
function modifier_drow_ranger_trueshot_lua_aura_effect:IsHidden() return false end
function modifier_drow_ranger_trueshot_lua_aura_effect:IsDebuff() return false end
function modifier_drow_ranger_trueshot_lua_aura_effect:IsPurgable() return false end

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
	return self.trueshot_ranged_damage * (self:GetAbility():GetCaster():GetBaseDamageMax()+self:GetAbility():GetCaster():GetBaseDamageMin())/2
end

----------------------------------------