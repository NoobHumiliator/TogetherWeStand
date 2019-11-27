require("util")

modifier_centaur_return_lua = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_centaur_return_lua:IsHidden()
    return true
end

function modifier_centaur_return_lua:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
-- Initializations

function modifier_centaur_return_lua:OnRefresh(kv)
    -- references
    self.base_damage = self:GetAbility():GetSpecialValueFor("return_damage") -- special value
    self.strength_pct = self:GetAbility():GetSpecialValueFor("strength_pct") -- special value
end

function modifier_centaur_return_lua:OnDestroy()

end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_centaur_return_lua:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_ATTACKED,
    }

    return funcs
end

function modifier_centaur_return_lua:OnAttacked(params)
    if IsServer() then
        local target = params.target
        local attacker = params.attacker

        if attacker:IsIllusion() or not target:IsConsideredHero() or target:PassivesDisabled() then
            return
        end

        if target ~= self:GetParent() or FlagExist(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then
            return
        end

        -- get damage
        local damage = self.base_damage + self:GetParent():GetStrength() * (self.strength_pct / 100)

        -- Apply Damage
        local damageTable = {
            victim = attacker,
            attacker = target,
            damage = damage,
            damage_type = DAMAGE_TYPE_PHYSICAL,
            damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
            ability = self:GetAbility(), --Optional.
        }
        ApplyDamage(damageTable)

        -- Play effects
        if attacker:IsConsideredHero() then
            self:PlayEffects(target, attacker)
        end
    end
end

--------------------------------------------------------------------------------
-- Graphics & Animations
-- function modifier_centaur_return_lua:GetEffectName()
-- 	return "particles/string/here.vpcf"
-- end
-- function modifier_centaur_return_lua:GetEffectAttachType()
-- 	return PATTACH_ABSORIGIN_FOLLOW
-- end
function modifier_centaur_return_lua:PlayEffects(target, attacker)
    local particle_cast = "particles/units/heroes/hero_centaur/centaur_return.vpcf"

    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(
    effect_cast,
    0,
    target,
    PATTACH_POINT_FOLLOW,
    "attach_hitloc",
    target:GetOrigin(), -- unknown
    true -- unknown, true
    )
    ParticleManager:SetParticleControlEnt(
    effect_cast,
    1,
    attacker,
    PATTACH_POINT_FOLLOW,
    "attach_hitloc",
    attacker:GetOrigin(), -- unknown
    true -- unknown, true
    )
end