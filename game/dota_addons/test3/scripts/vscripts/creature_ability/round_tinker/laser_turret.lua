function LaserStart(keys)
    Notifications:TopToAll({ ability = "tinker_laser" })
    Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, { text = "#laser_turret_dbm_simple", duration = 1.5, style = { color = "Azure" }, continue = true })

    local pathLength = 2000
    local numThinkers = 25
    local thinkerRadius = 192
    local ability = keys.ability
    local laser_angel = 0
    local caster = keys.caster
    local casterOrigin = caster:GetAbsOrigin()

    local particleName = "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf"
    local pfx = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(pfx, 0, caster:GetAbsOrigin() + Vector(0, 0, 96))
    ParticleManager:SetParticleControl(pfx, 1, caster:GetAbsOrigin() + Vector(300, 300, 96))

    local soundName = "Hero_Phoenix.SunRay.Beam"
    StartSoundEvent(soundName, caster)

    Timers:CreateTimer({
        endTime = 0.01,
        callback = function()
            if not caster:IsAlive() then
                ParticleManager:DestroyParticle(pfx, false)
                StopSoundEvent(soundName, caster)
                return nil
            else
                local endcapPos = Vector(casterOrigin.x + math.sin(math.rad(laser_angel)) * pathLength, casterOrigin.y + math.cos(math.rad(laser_angel)) * pathLength, casterOrigin.z)
                local location_for_turn = Vector(casterOrigin.x + math.sin(math.rad(laser_angel + 90)) * pathLength, casterOrigin.y + math.cos(math.rad(laser_angel + 90)) * pathLength, casterOrigin.z)
                caster:SetForwardVector((location_for_turn - casterOrigin):Normalized())
                local casterForward = (endcapPos - casterOrigin):Normalized()   --这里需要空余出背后的区域
                local units = FindUnitsInLine(DOTA_TEAM_BADGUYS, casterOrigin + casterForward * 200, endcapPos, nil, thinkerRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)

                -- 现在激光会被最近距离的敌方单位遮挡
                local minDistance = pathLength
                for _, unit in pairs(units) do
                    if not string.match(unit:GetUnitName(), "dummy") then
                        local distance = (casterOrigin - unit:GetOrigin()):Length()
                        if distance < minDistance then
                            minDistance = distance
                        end
                    end
                end
                minDistance = minDistance + 10
                endcapPos = Vector(casterOrigin.x + math.sin(math.rad(laser_angel)) * minDistance, casterOrigin.y + math.cos(math.rad(laser_angel)) * minDistance, casterOrigin.z)

                units = FindUnitsInLine(DOTA_TEAM_BADGUYS, casterOrigin + casterForward * 200, endcapPos, nil, thinkerRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
                for _, unit in pairs(units) do
                    if not string.match(unit:GetUnitName(), "dummy") then
                        ability:ApplyDataDrivenModifier(caster, unit, "modifier_laser_think_datadriven", { duration = 0.5 })
                        ApplyDamage({
                            victim    = unit,
                            attacker = caster,
                            damage    = unit:GetMaxHealth() * 0.003,
                            damage_type = DAMAGE_TYPE_PURE,
                            damage_flags = DOTA_DAMAGE_FLAG_NONE
                        })
                        local burnParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_sunray_beam_enemy.vpcf", PATTACH_ABSORIGIN, unit)
                        ParticleManager:SetParticleControlEnt(burnParticle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
                        ParticleManager:ReleaseParticleIndex(burnParticle)
                    end
                end
                laser_angel = laser_angel + 0.2
                ParticleManager:SetParticleControl(pfx, 1, endcapPos + Vector(0, 0, 96))
                return 0.01
            end
        end
    })
end