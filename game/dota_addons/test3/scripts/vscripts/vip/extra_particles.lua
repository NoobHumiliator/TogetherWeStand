function CreateVipParticle(hero)
    local e = ParticleManager:CreateParticle("particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControlEnt(e, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetOrigin(), true)
end

--function ep_create_xmax2015_top20(hero)
    --local e = ParticleManager:CreateParticle("particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hero)
    --ParticleManager:SetParticleControlEnt(e, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetOrigin(), true)
--end
