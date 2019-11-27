modifier_affixes_spike_warning = class({})

function modifier_affixes_spike_warning:IsHidden()
    return false
end

function modifier_affixes_spike_warning:GetEffectName()
    return "particles/econ/courier/courier_greevil_blue/courier_greevil_blue_ambient_1.vpcf"
end

function modifier_affixes_spike_warning:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_affixes_spike_warning:OnCreated()
    if not IsServer() then
        return
    end
end

function modifier_affixes_spike_warning:OnDestroy()
    if not IsServer() then
        return
    end
    self.spike_duration = self:GetAbility():GetSpecialValueFor("spike_duration")
    self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_affixes_spike", { duration = self.spike_duration })
end