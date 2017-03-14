LinkLuaModifier( "modifier_explode_expansion_thinker_aura", "creature_ability/modifier/modifier_explode_expansion_thinker_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_explode_expansion_thinker_aura_effect", "creature_ability/modifier/modifier_explode_expansion_thinker_aura_effect", LUA_MODIFIER_MOTION_NONE )


function ThinkerCreate( event )
	local caster = event.caster
	local ability = event.ability
    local init_radius = ability:GetSpecialValueFor( "init_radius" )

    local dummy = CreateUnitByName("npc_falling_rock_dummy", caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy:AddNewModifier(dummy,ability,"modifier_explode_expansion_thinker_aura",{})
    
end
