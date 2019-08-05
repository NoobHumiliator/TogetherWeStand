creature_centaur_shaman_ranged_attack = class({})

--------------------------------------------------------------------------------
function creature_centaur_shaman_ranged_attack:OnSpellStart()
    if IsServer() then
        self.attack_speed = self:GetSpecialValueFor("attack_speed")
        self.attack_width_initial = self:GetSpecialValueFor("attack_width_initial")
        self.attack_width_end = self:GetSpecialValueFor("attack_width_end")
        self.attack_distance = self:GetSpecialValueFor("attack_distance")
        self.attack_damage = self:GetSpecialValueFor("attack_damage")
        self.num_spawns = self:GetSpecialValueFor("num_spawns")

        local vPos = nil
        if self:GetCursorTarget() then
            vPos = self:GetCursorTarget():GetOrigin()
        else
            vPos = self:GetCursorPosition()
        end

        local vDirection = vPos - self:GetCaster():GetOrigin()
        vDirection.z = 0
        vDirection = vDirection:Normalized()

        self.attack_speed = self.attack_speed * (self.attack_distance / (self.attack_distance - self.attack_width_initial))

        local info = {
            --EffectName = "particles/test_particle/test_model_cluster_linear_projectile.vpcf",
            EffectName = "particles/units/heroes/hero_ember_spirit/ember_spirit_fire_remnant_trail.vpcf",
            Ability = self,
            vSpawnOrigin = self:GetCaster():GetOrigin(),
            fStartRadius = self.attack_width_initial,
            fEndRadius = self.attack_width_end,
            vVelocity = vDirection * self.attack_speed,
            fDistance = self.attack_distance,
            Source = self:GetCaster(),
            iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
            iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC + DOTA_UNIT_TARGET_BUILDING,
        }

        ProjectileManager:CreateLinearProjectile(info)
        EmitSoundOn("Hound.QuillAttack.Cast", self:GetCaster())
    end
end

--------------------------------------------------------------------------------
function creature_centaur_shaman_ranged_attack:OnProjectileHit(hTarget, vLocation)
    if IsServer() then
        if hTarget ~= nil and (not hTarget:IsMagicImmune()) and (not hTarget:IsInvulnerable()) then
            local damage = {
                victim = hTarget,
                attacker = self:GetCaster(),
                damage = self.attack_damage,
                damage_type = DAMAGE_TYPE_PHYSICAL,
                ability = self
            }

            ApplyDamage(damage)

            -- Create some units where the projectile hits
            for i = 1, self.num_spawns do
                if #self:GetCaster().hSpawnedUnits + 1 > self:GetCaster().nMaxSpawns then
                    break
                end

                local hCentaurScout = CreateUnitByName("npc_dota_creature_centaur_scout", vLocation, true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
                if hCentaurScout ~= nil then
                    hCentaurScout:SetInitialGoalEntity(hTarget)
                    table.insert(self:GetCaster().hSpawnedUnits, hCentaurScout)
                    if self:GetCaster().zone ~= nil then
                        self:GetCaster().zone:AddEnemyToZone(hCentaurScout)
                    end

                    local vRandomOffset = Vector(RandomInt(-20, 20), RandomInt(-20, 20), 0)
                    local vSpawnPoint = hTarget:GetAbsOrigin() + vRandomOffset
                    FindClearSpaceForUnit(hCentaurScout, vSpawnPoint, true)
                end
            end

            local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_bristleback/bristleback_quill_spray_impact.vpcf", PATTACH_CUSTOMORIGIN, hTarget)
            ParticleManager:SetParticleControlEnt(nFXIndex, 0, hTarget, PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), true)
            ParticleManager:SetParticleControlEnt(nFXIndex, 1, hTarget, PATTACH_POINT_FOLLOW, "attach_hitloc", hTarget:GetOrigin(), true)
            ParticleManager:SetParticleControlEnt(nFXIndex, 2, self:GetCaster(), PATTACH_ABSORIGIN_FOLLOW, nil, hTarget:GetOrigin(), true)
            ParticleManager:ReleaseParticleIndex(nFXIndex)

            EmitSoundOn("Hound.QuillAttack.Target", hTarget)
        end

        return true
    end
end