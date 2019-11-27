queenofpain_shadow_strike_lua = class({})
LinkLuaModifier("modifier_queenofpain_shadow_strike_lua", "heroes/hero_queenofpain/modifier_queenofpain_shadow_strike_lua", LUA_MODIFIER_MOTION_NONE)

function queenofpain_shadow_strike_lua:GetAOERadius()
    return FindTalentValue("special_bonus_unique_queen_of_pain", "value")
end

function queenofpain_shadow_strike_lua:GetBehavior()
    if self:GetCaster():HasModifier("modifier_special_bonus_unique_queen_of_pain") then
        return self.BaseClass.GetBehavior(self) + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return self.BaseClass.GetBehavior(self)
end

function queenofpain_shadow_strike_lua:OnCreated(kv)
    if self:GetCaster():HasModifier("modifier_special_bonus_unique_queen_of_pain") then
        return self.BaseClass.GetBehavior(self) + DOTA_ABILITY_BEHAVIOR_AOE
    end
    return self.BaseClass.GetBehavior(self)
end

--------------------------------------------------------------------------------
-- Ability Start
function queenofpain_shadow_strike_lua:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    
    local talent = caster:FindAbilityByName("special_bonus_unique_queen_of_pain")
    if talent and talent:GetLevel() > 0 then
        local range = talent:GetSpecialValueFor("value")
        local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, self:GetAbilityTargetType(), DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
        for _, unit in pairs(units) do
            if unit ~= target then
                local projectile_name = "particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf"
                local projectile_speed = self:GetSpecialValueFor("projectile_speed")
                local info = {
                    Target = unit,
                    Source = caster,
                    Ability = self,
                    EffectName = projectile_name,
                    iMoveSpeed = projectile_speed,
                    bReplaceExisting = false, -- Optional
                    bProvidesVision = false, -- Optional
                }
                ProjectileManager:CreateTrackingProjectile(info)
            end
        end
    end

    -- Create Projectile
    local projectile_name = "particles/units/heroes/hero_queenofpain/queen_shadow_strike.vpcf"
    local projectile_speed = self:GetSpecialValueFor("projectile_speed")
    local info = {
        Target = target,
        Source = caster,
        Ability = self,
        EffectName = projectile_name,
        iMoveSpeed = projectile_speed,
        bReplaceExisting = false, -- Optional
        bProvidesVision = false, -- Optional
    }
    ProjectileManager:CreateTrackingProjectile(info)

    -- Play effects
    local sound_cast = "Hero_QueenOfPain.ShadowStrike"
    EmitSoundOn(sound_cast, caster)
end
--------------------------------------------------------------------------------
-- Projectile
function queenofpain_shadow_strike_lua:OnProjectileHit(target, location)
    if target == nil or target:IsInvulnerable() or target:TriggerSpellAbsorb(self) then
        return
    end

    local debuffDuration = self:GetDuration()

    -- Add modifier
    target:AddNewModifier(
    self:GetCaster(), -- player source
    self, -- ability source
    "modifier_queenofpain_shadow_strike_lua", -- modifier name
    { duration = debuffDuration } -- kv
    )
end