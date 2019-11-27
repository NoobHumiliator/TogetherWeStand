modifier_smoke_breaking_aura = class({})

-----------------------------------------------------------------------------------------
function modifier_smoke_breaking_aura:IsHidden()
    return true
end

-----------------------------------------------------------------------------------------
function modifier_smoke_breaking_aura:IsPurgable()
    return false
end

----------------------------------------------------------------------------------------
function modifier_smoke_breaking_aura:IsDebuff()
    return false
end

function modifier_smoke_breaking_aura:OnCreated(kv)
    if self:GetParent():IsIllusion() then return end
    self:StartIntervalThink(0.2)
end

function modifier_smoke_breaking_aura:OnDestroy()
    self:StartIntervalThink(-1)
end

function modifier_smoke_breaking_aura:OnIntervalThink()
    if not IsServer() then return end
    local enemies = FindUnitsInRadius(
    self:GetParent():GetTeamNumber(),
    self:GetParent():GetOrigin(),
    nil,
    1025,
    DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
    FIND_ANY_ORDER,
    false
    )
    for _, enemy in pairs(enemies) do
        enemy:RemoveModifierByName("modifier_smoke_of_deceit")
        enemy:RemoveModifierByName("modifier_phantom_assassin_blur_active")
    end

end