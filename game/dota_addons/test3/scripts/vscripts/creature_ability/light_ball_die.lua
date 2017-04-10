function LightBallDie( event )
	local caster = event.caster
	local ability = event.ability
	local team = event.caster:GetTeamNumber()

    local caster_location=caster:GetAbsOrigin()
    local vector=Vector(caster_location.x,caster_location.y,0)
    vector.z= GetGroundHeight(vector,nil)
    local dummy = CreateUnitByName("npc_light_ball_dummy", vector, true, nil, nil, DOTA_TEAM_BADGUYS)
    --dummy:AddNewModifier(nil,nil,"modifier_kill",{duration=6})
    Timers:CreateTimer(6,function()
        dummy:ForceKill(true)
    end)

    local e = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6_lvl3_rays.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, dummy)
    ParticleManager:SetParticleControlEnt(e, 0, dummy, PATTACH_POINT_FOLLOW, "attach_hitloc", dummy:GetOrigin(), true)

	Notifications:BossAbilityDBM("light_ball_die")
end
