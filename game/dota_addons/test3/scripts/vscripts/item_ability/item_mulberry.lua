function SetMulberryBuff(keys)
    local caster = keys.caster
    local playerId = caster:GetPlayerOwnerID()
    local ability = keys.ability
    if caster:IsRealHero() then
        local stack_count = caster:GetModifierStackCount("modifier_item_mulberry", ability)
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_item_mulberry", {})
        caster:SetModifierStackCount("modifier_item_mulberry", ability, stack_count + 1)
        caster.mulberryAbility = ability
    end
    if caster and not caster:IsRealHero() then
        local hero = caster:GetOwner()
        local stack_count = hero:GetModifierStackCount("modifier_item_mulberry", ability)
        ability:ApplyDataDrivenModifier(hero, hero, "modifier_item_mulberry", {})
        hero:SetModifierStackCount("modifier_item_mulberry", ability, stack_count + 1)
        hero.mulberryAbility = ability
    end
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "UpdateFreeToSell", { free = true, playerId = playerId })
end