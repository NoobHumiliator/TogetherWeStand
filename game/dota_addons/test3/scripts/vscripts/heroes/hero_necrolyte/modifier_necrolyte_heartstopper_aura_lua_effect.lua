modifier_necrolyte_heartstopper_aura_lua_effect = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_necrolyte_heartstopper_aura_lua_effect:IsHidden()
    return self:GetCaster():CanEntityBeSeenByMyTeam(self:GetParent())
end

function modifier_necrolyte_heartstopper_aura_lua_effect:IsDebuff()
    return true
end

function modifier_necrolyte_heartstopper_aura_lua_effect:IsPurgable()
    return false
end

function modifier_necrolyte_heartstopper_aura_lua_effect:OnCreated(kv)
if not IsServer() then return end
    self.aura_damage = self:GetAbility():GetSpecialValueFor("aura_damage")
        local talent = self:GetCaster():FindAbilityByName("special_bonus_unique_necrophos_2")
        if talent and talent:GetLevel() > 0 then
            self.aura_damage = self.aura_damage + talent:GetSpecialValueFor("value")
        end
        self.aura_damage = self.aura_damage / 500
    self:StartIntervalThink(0.2)
end

function modifier_necrolyte_heartstopper_aura_lua_effect:OnRefresh(kv)
    self:OnCreated(kv)
end

function modifier_necrolyte_heartstopper_aura_lua_effect:OnDestroy()
    self:StartIntervalThink(-1)
end

function modifier_necrolyte_heartstopper_aura_lua_effect:OnIntervalThink()
    local damage_table = {}
    damage_table.attacker = self:GetCaster()
    damage_table.victim = self:GetParent()
    damage_table.damage_type = DAMAGE_TYPE_MAGICAL
    damage_table.ability = self:GetAbility()
    damage_table.damage = self:GetParent():GetMaxHealth() * self.aura_damage
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
    ApplyDamage(damage_table)
end