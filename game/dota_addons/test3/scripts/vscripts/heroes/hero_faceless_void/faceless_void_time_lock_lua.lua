faceless_void_time_lock_lua = class({})
LinkLuaModifier( "modifier_faceless_void_time_lock_passive", "heroes/hero_faceless_void/modifier_faceless_void_time_lock_passive", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------
function faceless_void_time_lock_lua:GetIntrinsicModifierName()
	return "modifier_faceless_void_time_lock_passive"
end
