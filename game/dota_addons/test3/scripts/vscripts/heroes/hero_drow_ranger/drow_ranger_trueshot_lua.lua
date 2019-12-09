drow_ranger_trueshot_lua = class({})
LinkLuaModifier( "modifier_drow_ranger_trueshot_lua_aura_effect", "heroes/drow_ranger/modifier_drow_ranger_trueshot_lua_aura_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_drow_ranger_trueshot_lua_aura", "heroes/drow_ranger/modifier_drow_ranger_trueshot_lua_aura", LUA_MODIFIER_MOTION_NONE )
--------------------------------------------------------------------------------

function drow_ranger_trueshot_lua:GetIntrinsicModifierName()
	return "modifier_drow_ranger_trueshot_lua_aura"
end

--------------------------------------------------------------------------------
function drow_ranger_trueshot_lua:OnSpellStart()
	if IsServer() then

	end
end
---------------------------------------------------------------------------------