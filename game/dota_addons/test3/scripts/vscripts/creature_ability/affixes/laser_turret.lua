function AffixesLaserStart(keys)

    Notifications:TopToAll({ ability = "tinker_laser" })
    Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, { text = "#laser_turret_dbm_simple", duration = 1.5, style = { color = "Azure" }, continue = true })

    local pathLength        = 2000
    local numThinkers        = 25
    local thinkerRadius    = 180
    local ability = keys.ability
    local laser_angel = 0
    local caster = keys.caster
    local casterOrigin = caster:GetAbsOrigin()

    local particleName = "particles/units/heroes/hero_phoenix/phoenix_sunray.vpcf"
    local pfx1
    local pfx2

    local count = 0

    local soundName = "Hero_Phoenix.SunRay.Beam"
    StartSoundEvent(soundName, caster)

    caster:AddNewModifier(nil, nil, "modifier_kill", { duration = 16 })  --设置强制死亡时间

    Timers:CreateTimer({
        endTime = 0.01,
        callback = function()

            count = count + 1

            caster.damageMultiple = 1 --激光炮台不受伤害加成影响

            if not caster:IsAlive() then
                --立即销毁模型
                caster:AddNoDraw()
                ParticleManager:DestroyParticle(pfx1, false)
                ParticleManager:ReleaseParticleIndex(pfx1)
                ParticleManager:DestroyParticle(pfx2, false)
                ParticleManager:ReleaseParticleIndex(pfx2)
                StopSoundEvent(soundName, caster)
                return nil
            else

                local endPos1 = Vector(casterOrigin.x + math.sin(math.rad(laser_angel)) * pathLength, casterOrigin.y + math.cos(math.rad(laser_angel)) * pathLength, casterOrigin.z)
                local endPos2 = Vector(casterOrigin.x - math.sin(math.rad(laser_angel)) * pathLength, casterOrigin.y - math.cos(math.rad(laser_angel)) * pathLength, casterOrigin.z)

                local location_for_turn = Vector(casterOrigin.x + math.sin(math.rad(laser_angel + 90)) * pathLength, casterOrigin.y + math.cos(math.rad(laser_angel + 90)) * pathLength, casterOrigin.z)
                caster:SetForwardVector((location_for_turn - casterOrigin):Normalized())

                if count == 150 then
                    pfx1 = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)
                    ParticleManager:SetParticleControl(pfx1, 0, caster:GetAbsOrigin() + Vector(0, 0, 96))
                    ParticleManager:SetParticleControl(pfx1, 1, endPos1 + Vector(0, 0, 96))

                    pfx2 = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN, caster)
                    ParticleManager:SetParticleControl(pfx2, 0, caster:GetAbsOrigin() + Vector(0, 0, 96))
                    ParticleManager:SetParticleControl(pfx2, 1, endPos2 + Vector(0, 0, 96))
                end

                if count > 150 then
                    local units = FindUnitsInLine(DOTA_TEAM_BADGUYS, endPos1, endPos2, nil, thinkerRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)

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
                    endPos2 = Vector(casterOrigin.x - math.sin(math.rad(laser_angel)) * minDistance, casterOrigin.y - math.cos(math.rad(laser_angel)) * minDistance, casterOrigin.z)
                    units = FindUnitsInLine(DOTA_TEAM_BADGUYS, endPos1, endPos2, nil, thinkerRadius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)

                    for _, unit in pairs(units) do
                        if not string.match(unit:GetUnitName(), "dummy") then
                            ability:ApplyDataDrivenModifier(caster, unit, "modifier_affixes_laser_think_datadriven", { duration = 0.5 })
                            ApplyDamage({
                                victim    = unit,
                                attacker = caster,
                                damage    = unit:GetMaxHealth() * 0.007,
                                damage_type = DAMAGE_TYPE_PURE,
                                damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
                            })
                            local burnParticle = ParticleManager:CreateParticle("particles/units/heroes/hero_phoenix/phoenix_sunray_beam_enemy.vpcf", PATTACH_ABSORIGIN, unit)
                            ParticleManager:SetParticleControlEnt(burnParticle, 1, unit, PATTACH_POINT_FOLLOW, "attach_hitloc", unit:GetAbsOrigin(), true)
                            ParticleManager:ReleaseParticleIndex(burnParticle)
                        end
                    end
                    ParticleManager:SetParticleControl(pfx1, 1, endPos1 + Vector(0, 0, 96))
                    ParticleManager:SetParticleControl(pfx2, 1, endPos2 + Vector(0, 0, 96))
                end
                laser_angel = laser_angel + 0.25
                return 0.01
            end
        end
    })

end