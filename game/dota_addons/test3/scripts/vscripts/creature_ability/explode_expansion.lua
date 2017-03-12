LinkLuaModifier( "modifier_explode_expansion_thinker_aura", "creature_ability/modifier/modifier_explode_expansion_thinker_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_explode_expansion_thinker_aura_effect", "creature_ability/modifier/modifier_explode_expansion_thinker_aura_effect", LUA_MODIFIER_MOTION_NONE )


function ThinkerCreate( event )
	local caster = event.caster
	local ability = event.ability
    local init_radius = ability:GetSpecialValueFor( "init_radius" )

    local dummy = CreateUnitByName("npc_falling_rock_dummy", caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
    dummy:AddNewModifier(dummy,ability,"modifier_explode_expansion_thinker_aura",{})
    

    local nFXIndex = ParticleManager:CreateParticle( "particles/wolf_pool_1.vpcf", PATTACH_ABSORIGIN, dummy )
	ParticleManager:SetParticleControl(nFXIndex, 0, dummy:GetAbsOrigin())
	ParticleManager:SetParticleControl(nFXIndex, 1, Vector(init_radius,1,1))
	--ParticleManager:SetParticleControl(nFXIndex, 15, Vector(255,153,102))
	--ParticleManager:SetParticleControl(nFXIndex, 16, Vector(1,0,0))


	local modifier=dummy:FindModifierByName("modifier_explode_expansion_thinker_aura")
	modifier.nFXIndex=nFXIndex
end
