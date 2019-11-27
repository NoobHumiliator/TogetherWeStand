creature_bandit_stifling_dagger = class({})

--------------------------------------------------------------------------------
function creature_bandit_stifling_dagger:OnSpellStart()
    self.duration = self:GetSpecialValueFor("duration")
    self.dagger_speed = self:GetSpecialValueFor("dagger_speed")
    self.dagger_offset = self:GetSpecialValueFor("dagger_offset")
    self.dagger_count = self:GetSpecialValueFor("dagger_count")
    self.dagger_rate = self:GetSpecialValueFor("dagger_rate")
    self.dagger_range = self:GetSpecialValueFor("dagger_range")

    self.vTargetLocation = self:GetCursorPosition()
    self.flAccumulatedTime = 0
    self.vDirection = self.vTargetLocation - self:GetCaster():GetOrigin()
    self.nDaggersThrown = 0

    local vDirection = self.vTargetLocation - self:GetCaster():GetOrigin()
    vDirection.z = 0
    vDirection = vDirection:Normalized()

    self:ThrowDagger(vDirection)
end

--------------------------------------------------------------------------------
function creature_bandit_stifling_dagger:OnChannelThink(flInterval)
    self.flAccumulatedTime = self.flAccumulatedTime + flInterval
    if self.flAccumulatedTime >= self.dagger_rate then
        self.flAccumulatedTime = self.flAccumulatedTime - self.dagger_rate

        local vOffset = RandomVector(self.dagger_offset)
        vOffset.z = 0

        local vDirection = (self.vTargetLocation + vOffset) - self:GetCaster():GetOrigin()
        vDirection.z = 0
        vDirection = vDirection:Normalized()

        self:ThrowDagger(vDirection)
    end
end

--------------------------------------------------------------------------------
function creature_bandit_stifling_dagger:OnProjectileHit(hTarget, vLocation)
    if hTarget ~= nil and (not hTarget:IsInvulnerable()) then
        local kv = {}
        self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_phantom_assassin_stiflingdagger_caster", kv)
        self:GetCaster():PerformAttack(hTarget, false, true, true, true, true, false, true)
        self:GetCaster():RemoveModifierByName("modifier_phantom_assassin_stiflingdagger_caster")

        local kv =         {
            duration = self.duration,
        }

        hTarget:AddNewModifier(self:GetCaster(), self, "modifier_phantom_assassin_stiflingdagger", kv)
        EmitSoundOn("Dungeon.BanditDagger.Target", hTarget)
    end

    return true
end

--------------------------------------------------------------------------------
function creature_bandit_stifling_dagger:ThrowDagger(vDirection)
    local info =     {
        EffectName = "particles/phantom_assassin_linear_dagger.vpcf",
        Ability = self,
        vSpawnOrigin = self:GetCaster():GetOrigin(),
        fStartRadius = 50,
        fEndRadius = 50,
        vVelocity = vDirection * self.dagger_speed,
        fDistance = self.dagger_range,
        Source = self:GetCaster(),
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    }

    ProjectileManager:CreateLinearProjectile(info)
    EmitSoundOn("Dungeon.BanditDagger.Cast", self:GetCaster())

    self.nDaggersThrown = self.nDaggersThrown + 1
    if self.nDaggersThrown >= self.dagger_count then
        self:EndChannel(false)
    else
        self:GetCaster():StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1.33)
    end
end

--------------------------------------------------------------------------------