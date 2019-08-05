function AddAbilityPoint(keys)
    local caster = keys.caster
    local playerId = caster:GetPlayerOwnerID()
    if caster:IsRealHero() then
        local p = caster:GetAbilityPoints()
        caster:SetAbilityPoints(p + 1)
    end
    if caster and not caster:IsRealHero() then
        local p = caster:GetOwner():GetAbilityPoints()
        caster:GetOwner():SetAbilityPoints(p + 1)
    end
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "UpdateAbilityList", { heroName = false, playerId = playerId })
end