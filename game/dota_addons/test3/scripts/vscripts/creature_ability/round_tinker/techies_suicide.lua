tinker_creature_techies_suicide = class({})
LinkLuaModifier("modifier_tinker_creature_techies_suicide_leap", "creature_ability/round_tinker/modifier_tinker_creature_techies_suicide_leap", LUA_MODIFIER_MOTION_BOTH)
--------------------------------------------------------------------------------
function tinker_creature_techies_suicide:OnAbilityPhaseStart()
    if IsServer() then
        local hp_cost = self:GetSpecialValueFor("hp_cost")
        if self:GetCaster():GetHealth() < (self:GetCaster():GetMaxHealth() * hp_cost / 100) then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_techies_suicide_leap_animation", { duration = 3 })
        end

        local radius = self:GetSpecialValueFor("radius")
        self.nPreviewFXIndex = ParticleManager:CreateParticle("particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(self.nPreviewFXIndex, 0, self:GetCursorPosition())
        ParticleManager:SetParticleControl(self.nPreviewFXIndex, 1, Vector(radius, -radius, -radius))
        ParticleManager:SetParticleControl(self.nPreviewFXIndex, 2, Vector(0.8, 0, 0))
        ParticleManager:ReleaseParticleIndex(self.nPreviewFXIndex)


    end

    return true
end

-------------------------------------------------------------------------------
function tinker_creature_techies_suicide:OnUpgrade()
    if IsServer() then
        self:StartCooldown(2.5)  --炸弹人出生 给与2.5秒的自爆CD
    end
    return true
end

--------------------------------------------------------------------------------
function tinker_creature_techies_suicide:OnAbilityPhaseStart()
    if IsServer() then
        local hp_cost = self:GetSpecialValueFor("hp_cost")
        if self:GetCaster():GetHealth() < (self:GetCaster():GetMaxHealth() * hp_cost / 100) then
            self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_techies_suicide_leap_animation", { duration = 3 })
        end

        local radius = self:GetSpecialValueFor("radius")
        self.nPreviewFXIndex = ParticleManager:CreateParticle("particles/econ/events/darkmoon_2017/darkmoon_calldown_marker.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(self.nPreviewFXIndex, 0, self:GetCursorPosition())
        ParticleManager:SetParticleControl(self.nPreviewFXIndex, 1, Vector(radius, -radius, -radius))
        ParticleManager:SetParticleControl(self.nPreviewFXIndex, 2, Vector(0.8, 0, 0))
        ParticleManager:ReleaseParticleIndex(self.nPreviewFXIndex)


    end

    return true
end

--------------------------------------------------------------------------------
function tinker_creature_techies_suicide:OnAbilityPhaseInterrupted()
    if IsServer() then
        self:GetCaster():RemoveModifierByName("modifier_techies_suicide_leap_animation")
    end
end

--------------------------------------------------------------------------------
function tinker_creature_techies_suicide:OnSpellStart()
    if IsServer() then
        local vLocation = self:GetCursorPosition()
        local kv =         {
            vLocX = vLocation.x,
            vLocY = vLocation.y,
            vLocZ = vLocation.z
        }
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_tinker_creature_techies_suicide_leap", kv)
        EmitSoundOn("Hero_Techies.BlastOff.Cast", self:GetCaster())
    end
end

--------------------------------------------------------------------------------
function tinker_creature_techies_suicide:BlowUp()
    if IsServer() then
        ParticleManager:DestroyParticle(self.nPreviewFXIndex, true)

        local radius = self:GetSpecialValueFor("radius")
        local damage = self:GetSpecialValueFor("damage")
        --print("sdadsadasd")
        local enemies = FindUnitsInRadius(self:GetCaster():GetTeamNumber(), self:GetCaster():GetOrigin(), self:GetCaster(), radius, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
        if #enemies > 0 then
            for _, enemy in pairs(enemies) do
                print("name " .. enemy:GetUnitName())
                local DamageInfo =                 {
                    victim = enemy,
                    attacker = self:GetCaster(),
                    ability = self,
                    damage = damage,
                    damage_type = DAMAGE_TYPE_PURE
                }
                ApplyDamage(DamageInfo)
            end
        end

        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_blast_off.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster():GetOrigin())
        ParticleManager:SetParticleControl(nFXIndex, 1, Vector(radius, 0, 1))
        ParticleManager:SetParticleControl(nFXIndex, 2, Vector(radius, 0, 1))
        ParticleManager:ReleaseParticleIndex(nFXIndex)

        EmitSoundOn("Hero_Techies.Suicide", self:GetCaster())
        GridNav:DestroyTreesAroundPoint(self:GetCaster():GetOrigin(), radius, false)
        if self:GetCaster():IsAlive() then
            local hp_cost = self:GetSpecialValueFor("hp_cost")
            local DamageInfo =             {
                victim = self:GetCaster(),
                attacker = self:GetCaster(),
                ability = self,
                damage = hp_cost * self:GetCaster():GetMaxHealth() / 100,
                damage_type = DAMAGE_TYPE_PURE,
                damage_flags = DOTA_DAMAGE_FLAG_HPLOSS + DOTA_DAMAGE_FLAG_REFLECTION + DOTA_DAMAGE_FLAG_NO_DAMAGE_MULTIPLIERS + DOTA_DAMAGE_FLAG_NO_SPELL_AMPLIFICATION,
            }
            ApplyDamage(DamageInfo)
        end
    end
end