LinkLuaModifier("modifier_spectre_dispersion_lua", "heroes/hero_spectre/modifier_spectre_dispersion_lua", LUA_MODIFIER_MOTION_NONE )

function ApplyModifier (keys)

	local caster = keys.caster
	local ability = keys.ability
	local modifier = "modifier_spectre_dispersion_lua"

	caster:AddNewModifier( caster, ability, modifier, {} )

end