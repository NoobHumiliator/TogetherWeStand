modifier_item_mage_shield_buff = class({})
LinkLuaModifier("modifier_item_mage_shield_1", "item_ability/modifier/modifier_item_mage_shield_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mage_shield_2", "item_ability/modifier/modifier_item_mage_shield_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mage_shield_3", "item_ability/modifier/modifier_item_mage_shield_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_mage_shield_4", "item_ability/modifier/modifier_item_mage_shield_buff", LUA_MODIFIER_MOTION_NONE)

function modifier_item_mage_shield_buff:IsHidden()
    return false
end

function modifier_item_mage_shield_buff:IsDebuff()
    return false
end

function modifier_item_mage_shield_buff:IsPurgable()
    return true
end

function modifier_item_mage_shield_buff:GetTexture()
    if self:GetParent():HasModifier("modifier_item_mage_shield_1") then
        return "item_mage_shield_1"
    elseif self:GetParent():HasModifier("modifier_item_mage_shield_2") then
        return "item_mage_shield_2"
    elseif self:GetParent():HasModifier("modifier_item_mage_shield_3") then
        return "item_mage_shield_3"
    else
        return "item_mage_shield_4"
    end
end

function modifier_item_mage_shield_buff:GetEffectName()
    return "particles/items_fx/immunity_sphere_buff.vpcf"
end

function modifier_item_mage_shield_buff:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_item_mage_shield_buff:OnCreated(kv)
    if not IsServer() then return end
    if self.modifier then
        self.modifier:Destroy()
    end
    self.modifier = self:GetParent():AddNewModifier(self:GetParent(), self:GetAbility(), "modifier_" .. self:GetAbility():GetAbilityName(), {})
    self.damage_per_mana = self:GetAbility():GetSpecialValueFor("damage_per_mana")
    EmitSoundOn("DOTA_Item.LinkensSphere.Activate", self:GetParent())
end

function modifier_item_mage_shield_buff:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_item_mage_shield_buff:OnDestroy()
    if not IsServer() then return end
    self.modifier:Destroy()
end

function modifier_item_mage_shield_buff:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE,
        MODIFIER_PROPERTY_MIN_HEALTH,
    }
    return funcs
end

function modifier_item_mage_shield_buff:OnTakeDamage(params)
    local caster = self:GetParent()
    if params.unit ~= caster then
        return
    end

    local damage = params.damage

    --来自队友的伤害不能被抵抗
    if damage >= caster:GetHealth() then --如果造成过量伤害
        local overDamage = damage - caster:GetHealth()
        caster:ReduceMana(overDamage / self.damage_per_mana)
        if caster:GetMana() < 5 then
            self:Destroy()
        end
    end
end

function modifier_item_mage_shield_buff:GetMinHealth(params)
    return 1
end

modifier_item_mage_shield_1 = class({})

function modifier_item_mage_shield_1:IsHidden()
    return true
end

function modifier_item_mage_shield_1:IsDebuff()
    return false
end

function modifier_item_mage_shield_1:IsPurgable()
    return true
end

modifier_item_mage_shield_2 = class({})

function modifier_item_mage_shield_2:IsHidden()
    return true
end

function modifier_item_mage_shield_2:IsDebuff()
    return false
end

function modifier_item_mage_shield_2:IsPurgable()
    return true
end

modifier_item_mage_shield_3 = class({})

function modifier_item_mage_shield_3:IsHidden()
    return true
end

function modifier_item_mage_shield_3:IsDebuff()
    return false
end

function modifier_item_mage_shield_3:IsPurgable()
    return true
end

modifier_item_mage_shield_4 = class({})

function modifier_item_mage_shield_4:IsHidden()
    return true
end

function modifier_item_mage_shield_4:IsDebuff()
    return false
end

function modifier_item_mage_shield_4:IsPurgable()
    return true
end