LinkLuaModifier( "modifier_explode_expansion_thinker_aura", "creature_ability/modifier/modifier_explode_expansion_thinker_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_explode_expansion_ally_aura", "creature_ability/modifier/modifier_explode_expansion_ally_aura", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_explode_expansion_thinker_aura_effect", "creature_ability/modifier/modifier_explode_expansion_thinker_aura_effect", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_explode_expansion_ally_aura_effect", "creature_ability/modifier/modifier_explode_expansion_ally_aura_effect", LUA_MODIFIER_MOTION_NONE )


function ThinkerCreate( event )
	local caster = event.caster
	local ability = event.ability
    local init_radius = ability:GetSpecialValueFor( "init_radius" )
     

    if not caster:HasModifier("modifier_explode_expansion_ally_aura_effect") then
        local dummy = CreateUnitByName("npc_geodesic_dummy", caster:GetAbsOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS)
        dummy:AddNewModifier(dummy,ability,"modifier_explode_expansion_thinker_aura",{})
        dummy:AddNewModifier(dummy,ability,"modifier_explode_expansion_ally_aura",{})
    end
    
end


function InitCountDown( event )

    local caster = event.caster
	local ability = event.ability
	local countDownParticle= ParticleManager:CreateParticle("particles/hw_fx/candy_carrying_stack.vpcf",PATTACH_OVERHEAD_FOLLOW,caster)
    caster.countDownParticle=countDownParticle
    caster.life_time=99
    caster.modelScale=caster:GetModelScale()
    ParticleManager:SetParticleControl(caster.countDownParticle,2, Vector(9,9,0))  --这里要改时间
end

function Onthink( event )

    local caster = event.caster
	local ability = event.ability
  
    caster.life_time=caster.life_time-1
    if caster.life_time<0 then 
        caster:ForceKill(true)
        return
    end
       
    caster:SetModelScale(caster.modelScale*(1+0.03* (99-caster.life_time) ))  --这里要改时间

	if caster.life_time<10 and caster.life_time>=0 then
	  ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(0,caster.life_time,0))
	else
	  ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(math.floor(caster.life_time/10),caster.life_time-math.floor(caster.life_time/10)*10,0))
	end
end
