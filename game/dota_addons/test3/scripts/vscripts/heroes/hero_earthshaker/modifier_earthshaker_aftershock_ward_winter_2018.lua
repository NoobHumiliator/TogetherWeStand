modifier_earthshaker_aftershock_ward_winter_2018 = class({})

--------------------------------------------------------------------------------
function modifier_earthshaker_aftershock_ward_winter_2018:IsAura()
    return true
end

--------------------------------------------------------------------------------
function modifier_earthshaker_aftershock_ward_winter_2018:GetModifierAura()
    return "modifier_ward_earthshaker_aftershock"
end
--------------------------------------------------------------------------------
function modifier_earthshaker_aftershock_ward_winter_2018:GetAuraSearchTeam()
    return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------
function modifier_earthshaker_aftershock_ward_winter_2018:GetAuraSearchType()
    return DOTA_UNIT_TARGET_HERO
end

--------------------------------------------------------------------------------
function modifier_earthshaker_aftershock_ward_winter_2018:GetAuraSearchFlags()
    return DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO
end
--------------------------------------------------------------------------------
function modifier_earthshaker_aftershock_ward_winter_2018:GetAuraRadius()
    return self.aura_radius
end

--------------------------------------------------------------------------------
function modifier_earthshaker_aftershock_ward_winter_2018:OnCreated(kv)
    self.aura_radius = self:GetAbility():GetSpecialValueFor("aura_radius")
end

--------------------------------------------------------------------------------
function modifier_earthshaker_aftershock_ward_winter_2018:CheckState()
    local state = {}
    if IsServer() then
        state[MODIFIER_STATE_ROOTED] = true
    end

    return state
end