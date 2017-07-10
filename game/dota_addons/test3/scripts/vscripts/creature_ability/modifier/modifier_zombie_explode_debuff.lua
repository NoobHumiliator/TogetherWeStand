modifier_zombie_explode_debuff = class({})


function modifier_zombie_explode_debuff:DeclareFunctions()
	local funcs = {}
	
	return funcs
end


function modifier_zombie_explode_debuff:IsPurgable()
	return false
end


function modifier_zombie_explode_debuff:GetTexture()
	return "nevermore_shadowraze1"
end


function modifier_zombie_explode_debuff:IsPermanent()
	return true
end


function modifier_zombie_explode_debuff:IsDebuff()
	return true
end