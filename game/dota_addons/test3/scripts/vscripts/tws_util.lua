function KillTiny()
    local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
    for _, unit in pairs(targets) do
        if string.match(unit:GetUnitName(), "npc_dota_tiny_") then
            unit.removedByMech = true
            unit:ForceKill(true)
        end
    end
end