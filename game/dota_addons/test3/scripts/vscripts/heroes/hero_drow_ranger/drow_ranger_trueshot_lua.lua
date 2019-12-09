drow_ranger_trueshot_lua = class({})
LinkLuaModifier( "modifier_drow_ranger_trueshot_lua_aura_effect", "heroes/hero_drow_ranger/modifier_drow_ranger_trueshot_lua_aura_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_drow_ranger_trueshot_lua_aura", "heroes/hero_drow_ranger/modifier_drow_ranger_trueshot_lua_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_drow_ranger_trueshot_lua_aura_creep", "heroes/hero_drow_ranger/modifier_drow_ranger_trueshot_lua_aura_creep", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function drow_ranger_trueshot_lua:GetIntrinsicModifierName()
	return "modifier_drow_ranger_trueshot_lua_aura"
end

--------------------------------------------------------------------------------
function drow_ranger_trueshot_lua:OnSpellStart()
	if IsServer() then
       self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_drow_ranger_trueshot_lua_aura_creep", { duration=self:GetDuration() } )
	end
end
---------------------------------------------------------------------------------