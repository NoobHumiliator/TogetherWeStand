LinkLuaModifier( "modifier_explode_expansion_thinker_aura", "creature_ability/modifier/modifier_explode_expansion_thinker_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_explode_expansion_thinker_aura_effect", "creature_ability/modifier/modifier_explode_expansion_thinker_aura_effect", LUA_MODIFIER_MOTION_NONE )


function ThinkerCreate( event )
	local caster = event.caster
	local ability = event.ability
	local hThinker = CreateModifierThinker( caster, ability, "modifier_explode_expansion_thinker_aura", { duration = 20 }, caster:GetOrigin(), caster:GetTeamNumber(), false )
end
