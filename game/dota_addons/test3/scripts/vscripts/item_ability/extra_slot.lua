function SendExtraSlotToClient(keys)
    local caster = keys.caster
    local playerId = caster:GetPlayerOwnerID()
    local maxSlotNumber = 6

    if caster:HasModifier("modifier_extra_slot_7_consume") then
        maxSlotNumber = 7
    end

    if caster:HasModifier("modifier_extra_slot_8_consume") then
        maxSlotNumber = 8
    end

    if caster:HasModifier("modifier_extra_slot_9_consume") then
        maxSlotNumber = 9
    end
    print("maxSlotNumber" .. maxSlotNumber)
    CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId), "UpdateAbilityList", { heroName = false, playerId = playerId, maxSlotNumber = maxSlotNumber })
end