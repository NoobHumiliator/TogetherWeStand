require("util")
LinkLuaModifier( "modifier_player_hidden_lua","abilities/modifier_player_hidden_lua", LUA_MODIFIER_MOTION_NONE )

--所有天辉生物创建的时候加上一个隐藏modifier
function AddPlayerHiddenModifier(keys)
    local caster	= keys.caster
	local ability	= keys.ability
	--print("caster"..caster:GetUnitName())
	caster:AddNewModifier(caster,ability,"modifier_player_hidden_lua",nil)
end