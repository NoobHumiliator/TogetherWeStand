require("util")
--[[Author: Nightborn
	Date: August 27, 2016
]]
modifier_nyx_spike = class({})

function modifier_nyx_spike:IsHidden()
    return false
end

function modifier_nyx_spike:IsDebuff()
    return false
end

function modifier_nyx_spike:IsPurgable()
    return false
end

function modifier_nyx_spike:GetTexture()
    return "nyx_assassin_spiked_carapace"
end

function modifier_nyx_spike:GetEffectName()
    return "particles/items_fx/blademail.vpcf"
end

function modifier_nyx_spike:GetEffectAttachType()
    return PATTACH_ABSORIGIN_FOLLOW
end

function modifier_nyx_spike:OnCreated(kv)
    if not IsServer() then
        return
    end
    EmitSoundOn("DOTA_Item.BladeMail.Activate", self:GetParent())
end

function modifier_nyx_spike:OnDestroy()
    if not IsServer() then
        return
    end
end

function modifier_nyx_spike:DeclareFunctions()
    local funcs = {
        MODIFIER_EVENT_ON_TAKEDAMAGE
    }
    return funcs
end

function modifier_nyx_spike:OnTakeDamage(params)
    -- PrintTable(params)
    local caster = self:GetParent()
    local attacker = params.attacker
    local damage = params.damage
    local ability = params.inflictor
    local damage_type = params.damage_type

    if params.unit ~= caster or FlagExist(params.damage_flags, DOTA_DAMAGE_FLAG_REFLECTION) then
        return
    end

    if attacker.damageMultiple ~= nil then
        damage = damage / attacker.damageMultiple
    end
    
    damage = DamageAmplify(attacker, ability, damage_type, damage)

    local damage_table = {}
    damage_table.attacker = caster
    damage_table.victim = attacker
    damage_table.damage_type = DAMAGE_TYPE_PURE
    damage_table.ability = self:GetAbility()
    damage_table.damage = damage * 0.6
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_REFLECTION
    ApplyDamage(damage_table)
end