require("util")
LinkLuaModifier( "modifier_on_health_gain_lua","abilities/modifier_on_health_gain_lua", LUA_MODIFIER_MOTION_NONE )



function AddHealGainModifier(keys)
    local caster	= keys.caster
	local ability	= keys.ability
	--print("caster"..caster:GetUnitName())
	caster:AddNewModifier(caster,ability,"modifier_on_health_gain_lua",nil)
end