modifier_axe_counter_helix_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_axe_counter_helix_lua:IsHidden()
    return true
end

function modifier_axe_counter_helix_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_axe_counter_helix_lua:OnCreated(kv)
    if not IsServer() then return end
    -- references
    self.radius = self:GetAbility():GetSpecialValueFor("radius")
    self.chance = self:GetAbility():GetSpecialValueFor("trigger_chance")
    self.damage = self:GetAbility():GetSpecialValueFor("damage")
    local talent = self:GetParent():FindAbilityByName("special_bonus_unique_axe_4")
    if talent and talent:GetLevel() > 0 then
        self.damage = self.damage + talent:GetSpecialValueFor("value")
    end

    -- precache damage
    self.damageTable = {
        -- victim = target,
        attacker = self:GetParent(),
        damage = self.damage,
        damage_type = DAMAGE_TYPE_PURE,
        ability = self:GetAbility(), --Optional.
        damage_flags = DOTA_DAMAGE_FLAG_NONE, --Optional.
    }
    -- ApplyDamage(damageTable)
end

function modifier_axe_counter_helix_lua:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_axe_counter_helix_lua:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_axe_counter_helix_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACK_LANDED,
    }

    return funcs
end

function modifier_axe_counter_helix_lua:OnAttackLanded(params)
    if IsServer() then
        if params.attacker:GetTeamNumber() == params.target:GetTeamNumber() then return end

        if params.attacker == self:GetParent() then
            local talent = params.attacker:FindAbilityByName("special_bonus_unique_axe_3")
            if talent == nil or talent:GetLevel() <= 0 then
                return
            end
        else
            if params.attacker:IsOther() or params.attacker:IsBuilding() then return end
            if params.target ~= self:GetParent() then return end
        end
        if self:GetParent():PassivesDisabled() then return end

        -- roll dice
        if RandomInt(1, 100) > self.chance then return end

        -- find enemies
        local enemies = FindUnitsInRadius(
        self:GetParent():GetTeamNumber(), -- int, your team number
        self:GetParent():GetOrigin(), -- point, center point
        nil, -- handle, cacheUnit. (not known)
        self.radius, -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY, -- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, -- int, type filter
        DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, -- int, flag filter
        0, -- int, order filter
        false	-- bool, can grow cache
        )
        -- damage
        for _, enemy in pairs(enemies) do
            self.damageTable.victim = enemy
            ApplyDamage(self.damageTable)
        end

        -- cooldown
        self:GetAbility():UseResources(false, false, true)

        -- effects
        self:PlayEffects()
    end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_axe_counter_helix_lua:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_axe/axe_attack_blur_counterhelix.vpcf"
    local sound_cast = "Hero_Axe.CounterHelix"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetParent())
    ParticleManager:ReleaseParticleIndex(effect_cast)

    -- Create Sound
    EmitSoundOn(sound_cast, self:GetParent())
end