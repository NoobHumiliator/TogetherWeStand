LinkLuaModifier("modifier_zombie_explode_debuff", "creature_ability/round_tombstone/modifier_zombie_explode_debuff", LUA_MODIFIER_MOTION_NONE)
require("util")

function LaunchWave(event)
    local caster = event.caster
    local casterOrigin = caster:GetAbsOrigin()
    local ability = event.ability
    local init_radius = ability:GetSpecialValueFor("init_radius")

    local directions
    local particleName

    if event.Type == 1 then
        directions = { Vector(1, 0, 0), Vector(-1, 0, 0), Vector(0, -1, 0), Vector(0, 1, 0) }
        particleName = "particles/econ/items/earthshaker/earthshaker_gravelmaw/earthshaker_fissure_gravelmaw_gold.vpcf"
    else
        directions = { Vector(1, 1, 0), Vector(-1, -1, 0), Vector(1, -1, 0), Vector(-1, 1, 0) }
        particleName = "particles/econ/items/earthshaker/egteam_set/hero_earthshaker_egset/earthshaker_fissure_egset.vpcf"
    end

    EmitSoundOnLocationWithCaster(casterOrigin, "Hero_EarthShaker.Fissure.Cast", caster)

    for i = 1, #directions do
        local direction = directions[i]
        local distance = 200

        local nFXIndex1 = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(nFXIndex1, 0, casterOrigin)
        ParticleManager:SetParticleControl(nFXIndex1, 1, casterOrigin + direction * 2500)
        ParticleManager:SetParticleControl(nFXIndex1, 2, Vector(1, 0, 0))

        local nFXIndex2 = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(nFXIndex2, 0, casterOrigin + direction * 2500)
        ParticleManager:SetParticleControl(nFXIndex2, 1, casterOrigin + direction * 5000)
        ParticleManager:SetParticleControl(nFXIndex2, 2, Vector(1, 0, 0))

        local nFXIndex3 = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(nFXIndex3, 0, casterOrigin + direction * 5000)
        ParticleManager:SetParticleControl(nFXIndex3, 1, casterOrigin + direction * 7500)
        ParticleManager:SetParticleControl(nFXIndex3, 2, Vector(1, 0, 0))

        local units = FindUnitsInLine(DOTA_TEAM_BADGUYS, casterOrigin + direction * 100, casterOrigin + direction * 7500, nil, 110, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD)
        for _, unit in pairs(units) do

            --施加强驱散
            unit:Purge(true, false, false, false, true) --净化
            -- 移除强保命buff
            RemoveDurableBuff(unit)

            local purgeParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_demonic_purge.vpcf", PATTACH_ABSORIGIN_FOLLOW, unit)

            Timers:CreateTimer({
                endTime = 1.5, --1.5秒后移除精华效果
                callback = function()
                    ParticleManager:DestroyParticle(purgeParticle, false)
                    ParticleManager:ReleaseParticleIndex(purgeParticle)
                end
            })

            if not unit:HasModifier("modifier_zombie_explode_debuff") then
                unit:AddNewModifier(caster, nil, "modifier_zombie_explode_debuff", {})
                unit:SetModifierStackCount("modifier_zombie_explode_debuff", nil, 1)
            else
                local stack_count = unit:GetModifierStackCount("modifier_zombie_explode_debuff", nil)
                unit:SetModifierStackCount("modifier_zombie_explode_debuff", nil, stack_count + 1)
            end
            local statck = unit:GetModifierStackCount("modifier_zombie_explode_debuff", nil)
            AddFOWViewer(DOTA_TEAM_GOODGUYS, unit:GetOrigin(), 500, 2, false)

            ApplyDamage({
                victim    = unit,
                attacker = caster,
                ability = ability,
                damage    = unit:GetMaxHealth() * 0.1 * statck,
                damage_type = DAMAGE_TYPE_PURE,
                damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_BYPASSES_INVULNERABILITY
            })
        end
    end
end