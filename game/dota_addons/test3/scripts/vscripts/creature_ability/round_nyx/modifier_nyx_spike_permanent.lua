modifier_nyx_spike_permanent = class({})

function modifier_nyx_spike_permanent:IsHidden()
    return true
end

function modifier_nyx_spike_permanent:IsPassive()
    return true
end

function modifier_nyx_spike_permanent:IsDebuff()
    return false
end

function modifier_nyx_spike_permanent:IsPurgable()
    return false
end

function modifier_nyx_spike_permanent:OnCreated(kv)
    if not IsServer() then
        return
    end
    self.active_interval = self:GetAbility():GetSpecialValueFor("active_interval")
    self.warning_duration = self:GetAbility():GetSpecialValueFor("warning_duration")
    if self.active_interval > 0 then
        self:StartIntervalThink(self.active_interval)
    end
end

function modifier_nyx_spike_permanent:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_nyx_spike_permanent:OnIntervalThink()
    self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_nyx_spike_warning", { duration = self.warning_duration })
end