item_ogre_seal_totem = class({})
LinkLuaModifier("modifier_item_ogre_seal_totem", "item_ability/modifier/modifier_item_ogre_seal_totem", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("modifier_ogreseal_flop", "item_ability/modifier/modifier_ogreseal_flop", LUA_MODIFIER_MOTION_BOTH)

--------------------------------------------------------------------------------
function item_ogre_seal_totem:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

--------------------------------------------------------------------------------
function item_ogre_seal_totem:GetIntrinsicModifierName()
    return "modifier_item_ogre_seal_totem"
end

--------------------------------------------------------------------------------
function item_ogre_seal_totem:OnAbilityPhaseStart()
    if IsServer() then
        --self:GetCaster():StartGesture( ACT_DOTA_VICTORY )
    end

    return true
end

--------------------------------------------------------------------------------
function item_ogre_seal_totem:OnAbilityPhaseInterrupted()
    if IsServer() then
        ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)

        --self:GetCaster():RemoveGesture( ACT_DOTA_VICTORY )
        self:GetCaster():RemoveModifierByName("modifier_techies_suicide_leap_animation")
    end
end

--------------------------------------------------------------------------------
function item_ogre_seal_totem:OnSpellStart()
    if IsServer() then
        if self.nPreviewFXIndex then
            ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)
        end

        --self:GetCaster():RemoveGesture( ACT_DOTA_VICTORY )
        self.stun_duration = self:GetSpecialValueFor("stun_duration")

        local vToTarget = self:GetCursorPosition() - self:GetCaster():GetOrigin()
        vToTarget = vToTarget:Normalized()
        local vLocation = self:GetCaster():GetOrigin() + vToTarget * 25
        local kv =         {
            vLocX = vLocation.x,
            vLocY = vLocation.y,
            vLocZ = vLocation.z
        }
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_ogreseal_flop", kv)
        EmitSoundOn("Hero_Techies.BlastOff.Cast", self:GetCaster())
    end
end

--------------------------------------------------------------------------------
function item_ogre_seal_totem:TryToDamage()
    if IsServer() then
        local radius = self:GetSpecialValueFor("radius")
        local damage = self:GetSpecialValueFor("damage")
        local silence_duration = self:GetSpecialValueFor("silence_duration")
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS, 0, false)
        if #enemies > 0 then
            for _, enemy in pairs(enemies) do
                if (not enemy:IsMagicImmune()) and (not enemy:IsInvulnerable()) then
                    local DamageInfo =                     {
                        victim = enemy,
                        attacker = self:GetCaster(),
                        ability = self,
                        damage = damage,
                        damage_type = DAMAGE_TYPE_PHYSICAL,
                    }
                    ApplyDamage(DamageInfo)
                    if enemy:IsAlive() == false and enemy:GetUnitName() ~= "npc_dota_crate" and enemy:GetUnitName() ~= "npc_dota_vase" then
                        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_phantom_assassin/phantom_assassin_crit_impact.vpcf", PATTACH_CUSTOMORIGIN, nil)
                        ParticleManager:SetParticleControlEnt(nFXIndex, 0, enemy, PATTACH_POINT_FOLLOW, "attach_hitloc", enemy:GetOrigin(), true)
                        ParticleManager:SetParticleControl(nFXIndex, 1, enemy:GetOrigin())
                        ParticleManager:SetParticleControlForward(nFXIndex, 1, -self:GetCaster():GetForwardVector())
                        ParticleManager:SetParticleControlEnt(nFXIndex, 10, enemy, PATTACH_ABSORIGIN_FOLLOW, nil, enemy:GetOrigin(), true)
                        ParticleManager:ReleaseParticleIndex(nFXIndex)

                        EmitSoundOn("Dungeon.BloodSplatterImpact", enemy)
                    else
                        enemy:AddNewModifier(self:GetCaster(), self, "modifier_stunned", { duration = self.stun_duration })
                    end
                end
            end
        end

        EmitSoundOnLocationWithCaster(self:GetCaster():GetOrigin(), "OgreTank.GroundSmash", self:GetCaster())
        local nFXIndex = ParticleManager:CreateParticle("particles/test_particle/ogre_melee_smash.vpcf", PATTACH_WORLDORIGIN, self:GetCaster())
        ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster():GetOrigin())
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(self.radius, self.radius, self.radius))
        ParticleManager:ReleaseParticleIndex(nFXIndex)

        GridNav:DestroyTreesAroundPoint(self:GetCaster():GetOrigin(), radius, false)
    end
end