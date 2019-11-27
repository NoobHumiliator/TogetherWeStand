modifier_item_mulberry = class({})
LinkLuaModifier("modifier_item_mulberry", "item_ability/item_mulberry", LUA_MODIFIER_MOTION_NONE)

function modifier_item_mulberry:IsHidden()
    return false
end

function modifier_item_mulberry:IsDebuff()
    return false
end

function modifier_item_mulberry:IsPurgable()
    return false
end

function modifier_item_mulberry:IsPermanent()
    return true
end

function modifier_item_mulberry:RemoveOnDeath()
    return false
end

function modifier_item_mulberry:GetTexture()
    return "item_mulberry"
end

function SetMulberryBuff(keys)
    local caster = keys.caster
    local playerId = caster:GetPlayerOwnerID()
    local ability = keys.ability
    if not caster:IsRealHero() then
        caster = caster:GetOwner()
    end
    local modifier = caster:FindModifierByName("modifier_item_mulberry")
    local stack_count = 0
    if modifier then
        stack_count = modifier:GetStackCount()
    else
        modifier = caster:AddNewModifier(caster, ability, "modifier_item_mulberry", {})
    end
    caster:SetModifierStackCount("modifier_item_mulberry", ability, stack_count + 1)
    caster.mulberryAbility = ability
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "UpdateFreeToSell", { free = true, playerId = playerId })
end