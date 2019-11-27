modifier_affixes_spike_permanent = class({})

function modifier_affixes_spike_permanent:IsHidden()
    return true
end

function modifier_affixes_spike_permanent:IsPassive()
    return true
end

function modifier_affixes_spike_permanent:IsDebuff()
    return false
end

function modifier_affixes_spike_permanent:IsPurgable()
    return false
end

function modifier_affixes_spike_permanent:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.active_interval = self:GetAbility():GetSpecialValueFor("active_interval")
    self.warning_duration = self:GetAbility():GetSpecialValueFor("warning_duration")
    if self.active_interval > 0 then
        self:StartIntervalThink(0.5)
    end
end

function modifier_affixes_spike_permanent:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_affixes_spike_permanent:OnIntervalThink()
    if (GameRules:GetGameTime() % self.active_interval) < (self.warning_duration - 0.5) and not self:GetParent():HasModifier("modifier_affixes_spike_warning") then
        self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_affixes_spike_warning", { duration = self.warning_duration })
    end
end