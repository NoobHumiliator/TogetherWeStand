rubick_boss_passive = class({})
LinkLuaModifier("modifier_rubick_boss_passive", "creature_ability/round_rubick/modifier_rubick_boss_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_boss_flying", "creature_ability/round_rubick/modifier_rubick_boss_flying", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_boss_telekinesis_land_damage", "creature_ability/round_rubick/modifier_rubick_boss_telekinesis_land_damage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_boss_spell_steal_windup", "creature_ability/round_rubick/modifier_rubick_boss_spell_steal_windup", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_boss_minion_building_damage", "creature_ability/round_rubick/modifier_rubick_boss_minion_building_damage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_rubick_boss_spell_steal_thinker", "creature_ability/round_rubick/modifier_rubick_boss_spell_steal_thinker", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------
function rubick_boss_passive:GetIntrinsicModifierName()
    return "modifier_rubick_boss_passive"
end

--------------------------------------------------------------------------------
function rubick_boss_passive:OnProjectileHitHandle(hTarget, vLocation, nProjectileHandle)
    if IsServer() then
        local SpellStealInfo = nil
        local nToRemove = nil

        if hTarget ~= nil then
            if hTarget.nFXIndex ~= nil then
                ParticleManager:DestroyParticle(hTarget.nFXIndex, false)
            end
            local hBuff = hTarget:FindModifierByName("modifier_rubick_boss_spell_steal_thinker")
            if hBuff ~= nil then
                hBuff:Activate()
            end
        end
    end
    return true
end