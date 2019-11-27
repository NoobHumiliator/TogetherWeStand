require("vip/econ")

-- modifier_particle_model_scale = class({})
-- LinkLuaModifier("modifier_particle_model_scale", "vip/econ_manager", LUA_MODIFIER_MOTION_NONE)

-- -----------------------------------------------------------------------------------------
-- function modifier_particle_model_scale:IsHidden()
--     return true
-- end

-- function modifier_particle_model_scale:IsPurgable()
--     return false
-- end

-- function modifier_particle_model_scale:IsDebuff()
--     return false
-- end

-- function modifier_particle_model_scale:IsPermanent()
--     return true
-- end

-- -----------------------------------------------------------------------------------------
-- function modifier_particle_model_scale:DeclareFunctions()
--     local funcs = {
--         MODIFIER_PROPERTY_MODEL_SCALE
--     }
--     return funcs
-- end

-- function modifier_particle_model_scale:OnCreated(kv)
--     self.model_scale = kv.model_scale
-- end

-- function modifier_particle_model_scale:OnRefresh(kv)
--     self.model_scale = kv.model_scale
-- end

-- ----------------------------------------
-- function modifier_particle_model_scale:GetModifierModelScale()
--     return self.model_scale
-- end

----------------------------------------
function CHoldoutGameMode:ConfirmParticle(keys)
    local particleName = keys.particleName
    if particleName and PlayerResource:HasSelectedHero(keys.playerId) then
        local hero = PlayerResource:GetSelectedHeroEntity(keys.playerId)
        if not hero:IsAlive() then
            return
        end
        if Econ["OnEquip_" .. particleName .. "_server"] then
            Econ["OnEquip_" .. particleName .. "_server"](hero)
            -- local model_scale = 10
            -- if string.match(particleName, "legion_wings") then
            --     model_scale = 20
            --     if string.match(particleName, "legion_wings_vip") then
            --         model_scale = 50
            --     end
            -- end
            -- hero:AddNewModifier(hero, nil, "modifier_particle_model_scale", { model_scale = model_scale })
        end
    end
end



function CHoldoutGameMode:CancleParticle(keys)
    if PlayerResource:HasSelectedHero(keys.playerId) then
        local hero = PlayerResource:GetSelectedHeroEntity(keys.playerId)
        if hero:IsAlive() then
            --hero:RemoveModifierByName("modifier_particle_model_scale")
            RemoveAllParticlesOnHero(hero)
        end
    end
end