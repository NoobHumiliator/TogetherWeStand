modifier_affixes_falling_rock = class({})
LinkLuaModifier("modifier_affixes_falling_rock_thinker", "creature_ability/modifier/modifier_affixes_falling_rock", LUA_MODIFIER_MOTION_NONE)

function modifier_affixes_falling_rock:IsHidden()
    return true
end

function modifier_affixes_falling_rock:IsDebuff()
    return true
end

function modifier_affixes_falling_rock:IsPassive()
    return false
end

function modifier_affixes_falling_rock:IsPurgable()
    return false
end

function modifier_affixes_falling_rock:GetAttributes()
    return MODIFIER_ATTRIBUTE_PERMANENT
end

function modifier_affixes_falling_rock:OnCreated(kv)
    if not IsServer() then return end
    self:StartIntervalThink(1.8)
end

function modifier_affixes_falling_rock:OnIntervalThink()
    CreateModifierThinker(
    nil, --self:GetCaster(), -- player source
    nil, -- ability source
    "modifier_affixes_falling_rock_thinker", -- modifier name
    { duration = 5 }, -- kv
    self:GetCaster():GetOrigin() + RandomVector(RandomFloat(50, 900)),
    DOTA_TEAM_BADGUYS,
    false
    )
end

modifier_affixes_falling_rock_thinker = class({})

function modifier_affixes_falling_rock_thinker:IsHidden()
    return false
end

-- function modifier_affixes_falling_rock_thinker:GetEffectName()
--     return "particles/dire_fx/dire_lava_falling_rocks.vpcf"
-- end

-- function modifier_affixes_falling_rock_thinker:GetEffectAttachType()
--     return PATTACH_ABSORIGIN_FOLLOW
-- end

function modifier_affixes_falling_rock_thinker:OnCreated(kv)
    if not IsServer() then return end
    self:GetParent():SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)

    local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_shadow_demon/shadow_demon_soul_catcher_v2_ground01.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 1, self:GetParent():GetAbsOrigin())
    ParticleManager:SetParticleControl(effect_cast, 2, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)

    local effect_cast2 = ParticleManager:CreateParticle("particles/dire_fx/dire_lava_falling_rocks.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:SetParticleControl(effect_cast2, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast2)

    EmitSoundOn("DOTA_Item.Butterfly", self:GetParent())
    self.damage_table = {}
    self.damage_table.attacker = self:GetParent()
    self.damage_table.damage_type = DAMAGE_TYPE_PURE
    self.damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
    self.intervalTimes = 0
    self:StartIntervalThink(2.25)
end

function modifier_affixes_falling_rock_thinker:OnIntervalThink()
    local effect_cast = ParticleManager:CreateParticle("particles/units/heroes/hero_ember_spirit/ember_spirit_hit_fire.vpcf", PATTACH_ABSORIGIN_FOLLOW, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(effect_cast)
    if self.intervalTimes == 0 then
    EmitSoundOn("Ability.TossImpact", self:GetParent())
    end

    local units = FindUnitsInRadius(DOTA_TEAM_BADGUYS, self:GetParent():GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false) 
    for _, unit in pairs(units) do
        self.damage_table.victim = unit
        self.damage_table.damage = unit:GetMaxHealth() * 0.25
        ApplyDamage(self.damage_table)
        unit:AddNewModifier(unit, nil, "modifier_stunned", { duration = 0.5 })
    end
    
    local caster = self:GetParent()
    local flTimeCount = 0
    Timers:CreateTimer({
        endTime = 0.25,
        callback = function()
            local victims = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
            for _, victim in pairs(victims) do
                local damage = victim:GetMaxHealth() * 0.05
                local damage_table = {}
                damage_table.attacker = caster
                damage_table.victim = victim
                damage_table.damage_type = DAMAGE_TYPE_PURE
                damage_table.damage = damage
                damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
                ApplyDamage(damage_table)
            end
            flTimeCount = flTimeCount + 0.25
            if flTimeCount > 2.4 then
                return nil
            else
                return 0.25
            end
        end
    })
    self.intervalTimes = self.intervalTimes + 1
end