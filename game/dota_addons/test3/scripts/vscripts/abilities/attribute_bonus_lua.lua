attribute_bonus_lua = class({})
LinkLuaModifier( "modifier_attribute_bonus_lua","abilities/modifier_attribute_bonus_lua",LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function attribute_bonus_lua:GetIntrinsicModifierName()
	return "modifier_attribute_bonus_lua"
end
--------------------------------------------------------------------------------