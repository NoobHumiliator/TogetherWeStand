function EconRemoveParticle(pid)
    ParticleManager:DestroyParticle(pid, true)
    ParticleManager:ReleaseParticleIndex(pid)
end

function EconCreateParticleOnHero(hero, particleName)
    local pid = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, hero)
    ParticleManager:SetParticleControlEnt(pid, 0, hero, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", hero:GetAbsOrigin(), true)
    return pid
end

function RemoveAllParticlesOnHero(hero)  --移除全部VIP特效

    if hero.nParticleLegionWingsVip then
        EconRemoveParticle(hero.nParticleLegionWingsVip)
        hero.nParticleLegionWingsVip = nil
    end
    if hero.nParticleLegionWings then
        EconRemoveParticle(hero.nParticleLegionWings)
        hero.nParticleLegionWings = nil
    end
    if hero.nParticleLegionWings then
        EconRemoveParticle(hero.nParticleLegionWings)
        hero.nParticleLegionWings = nil
    end
    if hero.nParticleDevourlingGold then
        EconRemoveParticle(hero.nParticleDevourlingGold)
        hero.nParticleDevourlingGold = nil
    end
    if hero.nParticlePBR then
        EconRemoveParticle(hero.nParticlePBR)
        hero.nParticlePBR = nil
    end
    if hero.nParticleLavaTrail then
        EconRemoveParticle(hero.nParticleLavaTrail)
        hero.nParticleLavaTrail = nil
    end
    if hero.nDarkMoonParticle then
        EconRemoveParticle(hero.nDarkMoonParticle)
        hero.nDarkMoonParticle = nil
    end
    if hero.nDarkMoonParticleGround then
        EconRemoveParticle(hero.nDarkMoonParticleGround)
        hero.nDarkMoonParticleGround = nil
    end
    if hero.nParticle_sakura_trail1 then
        EconRemoveParticle(hero.nParticle_sakura_trail1)
        hero.nParticle_sakura_trail1 = nil
    end
    if hero.nParticle_sakura_trail2 then
        EconRemoveParticle(hero.nParticle_sakura_trail2)
        hero.nParticle_sakura_trail2 = nil
    end
    if hero.nParticleRex then
        EconRemoveParticle(hero.nParticleRex)
        hero.nParticleRex = nil
    end
    if hero.nParticleFrull then
        EconRemoveParticle(hero.nParticleFrull)
        hero.nParticleFrull = nil
    end
    if hero.nParticleBlack then
        EconRemoveParticle(hero.nParticleBlack)
        hero.nParticleBlack = nil
    end

end



Econ = {}



-----------------------------------------------------------------------------------------------------------------------
-- 军团之翼 天梯第一
Econ.OnEquip_legion_wings_vip_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticleLegionWingsVip = EconCreateParticleOnHero(hero, "particles/econ/legion_wings/legion_wings_vip.vpcf")
end
Econ.OnRemove_legion_wings_vip_server = function(hero)
    if hero.nParticleLegionWingsVip then
        EconRemoveParticle(hero.nParticleLegionWingsVip)
    end
end
Econ.OnEquip_legion_wings_vip_client = Econ.OnEquip_legion_wings_vip_server
Econ.OnRemove_legion_wings_vip_client = Econ.OnRemove_legion_wings_vip_server
-----------------------------------------------------------------------------------------------------------------------
-- 军团之翼 天梯前3
Econ.OnEquip_legion_wings_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticleLegionWings = EconCreateParticleOnHero(hero, "particles/econ/legion_wings/legion_wings.vpcf")
end
Econ.OnRemove_legion_wings_server = function(hero)
    if hero.nParticleLegionWings then
        EconRemoveParticle(hero.nParticleLegionWings)
    end
end
Econ.OnEquip_legion_wings_client = Econ.OnEquip_legion_wings_server
Econ.OnRemove_legion_wings_client = Econ.OnRemove_legion_wings_server
-----------------------------------------------------------------------------------------------------------------------
--冰冻气息  天梯前5
Econ.OnEquip_devourling_gold_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticleDevourlingGold = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_roshan_frost/courier_roshan_frost_ambient.vpcf")
end

Econ.OnRemove_devourling_gold_server = function(hero)
    if hero.nParticleDevourlingGold then
        EconRemoveParticle(hero.nParticleDevourlingGold)
    end
end
Econ.OnEquip_devourling_gold_client = Econ.OnEquip_devourling_gold_server
Econ.OnRemove_devourling_gold_server = Econ.OnRemove_devourling_gold_server
-----------------------------------------------------------------------------------------------------------------------
-- 粒子之气   天梯前10
Econ.OnEquip_paltinum_baby_roshan_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticlePBR = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf")
end
Econ.OnRemove_paltinum_baby_roshan_server = function(hero)
    if hero.nParticlePBR then
        EconRemoveParticle(hero.nParticlePBR)
    end
end
Econ.OnEquip_paltinum_baby_roshan_client = Econ.OnEquip_paltinum_baby_roshan_server
Econ.OnRemove_paltinum_baby_roshan_client = Econ.OnRemove_paltinum_baby_roshan_server
-----------------------------------------------------------------------------------------------------------------------
-- 熔岩之径  天梯前15
Econ.OnEquip_lava_trail_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticleLavaTrail = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_trail_lava/courier_trail_lava.vpcf")
end

Econ.OnRemove_lava_trail_server = function(hero)
    if hero.nParticleLavaTrail then
        EconRemoveParticle(hero.nParticleLavaTrail)
    end
end
Econ.OnEquip_lava_trail_client = Econ.OnEquip_lava_trail_server
Econ.OnRemove_lava_trail_client = Econ.OnRemove_lava_trail_server
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-- 暗月腐化 VIP
Econ.OnEquip_darkmoon_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nDarkMoonParticle = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon.vpcf")
    hero.nDarkMoonParticleGround = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_ground.vpcf")
end
Econ.OnRemove_darkmoon_server = function(hero)
    if hero.nDarkMoonParticle then
        EconRemoveParticle(hero.nDarkMoonParticle)
    end
    if hero.nDarkMoonParticleGround then
        EconRemoveParticle(hero.nDarkMoonParticleGround)
    end
end
Econ.OnEquip_darkmoon_client = Econ.OnEquip_darkmoon_server
Econ.OnRemove_darkmoon_client = Econ.OnRemove_darkmoon_server
------------------------------------------------------------------------------------------------------------------------------------
-- Fissured Soul VIP
Econ.OnEquip_sakura_trail_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticle_sakura_trail1 = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_axolotl_ambient/courier_axolotl_ambient.vpcf")
    hero.nParticle_sakura_trail2 = EconCreateParticleOnHero(hero, "particles/econ/sakura_trail.vpcf")
    ParticleManager:SetParticleControl(hero.nParticle_sakura_trail2, 8, Vector(20, 0, 0))
end
Econ.OnRemove_sakura_trail_server = function(hero)
    if hero.nParticle_sakura_trail1 then
        EconRemoveParticle(hero.nParticle_sakura_trail1)
    end
    if hero.nParticle_sakura_trail2 then
        EconRemoveParticle(hero.nParticle_sakura_trail2)
    end
end
Econ.OnEquip_sakura_trail_client = Econ.OnEquip_sakura_trail_server
Econ.OnRemove_sakura_trail_client = Econ.OnRemove_sakura_trail_server

----------------------------------------------------------------------------------------------------------------------------
-- 紫气缭绕
Econ.OnEquip_rex_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticleRex = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_trail_orbit/courier_trail_orbit.vpcf")
end

Econ.OnRemove_rex_server = function(hero)
    if hero.nParticleRex then
        EconRemoveParticle(hero.nParticleRex)
    end
end
Econ.OnEquip_rex_client = Econ.OnEquip_rex_server
Econ.OnRemove_rex_server = Econ.OnRemove_rex_server
----------------------------------------------------------------------------------------------------------------------------
-- 脚下长草 VIP
Econ.OnEquip_frull_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticleFrull = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_greevil_green/courier_greevil_green_ambient_3.vpcf")
end

Econ.OnRemove_frull_server = function(hero)
    if hero.nParticleFrull then
        EconRemoveParticle(hero.nParticleFrull)
    end
end
Econ.OnEquip_frull_client = Econ.OnEquip_frull_server
Econ.OnRemove_frull_server = Econ.OnRemove_frull_server
-----------------------------------------------------------------------------------------------------------------------------
-- 另一种火焰  VIP
Econ.OnEquip_black_server = function(hero)
    RemoveAllParticlesOnHero(hero)
    hero.nParticleBlack = EconCreateParticleOnHero(hero, "particles/econ/courier/courier_greevil_red/courier_greevil_red_ambient_3.vpcf")
end

Econ.OnRemove_black_server = function(hero)
    if hero.nParticleBlack then
        EconRemoveParticle(hero.nParticleBlack)
    end
end
Econ.OnEquip_black_client = Econ.OnEquip_black_server
Econ.OnRemove_black_server = Econ.OnRemove_black_server
-----------------------------------------------------------------------------------------------------------------------------