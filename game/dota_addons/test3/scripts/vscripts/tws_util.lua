function KillTiny()
    local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
    for _,unit in pairs(targets) do
        if unit:GetUnitName()==("npc_dota_tiny_1") or unit:GetUnitName()==("npc_dota_tiny_2")  or unit:GetUnitName()==("npc_dota_tiny_3") or unit:GetUnitName()==("npc_dota_tiny_4") or unit:GetUnitName()==("npc_dota_tiny_5") then
            unit.removedByMech=true
            unit:ForceKill(true)
        end
    end
end
