function Suicide(keys)
    local caster = keys.caster
    local caster_location = caster:GetAbsOrigin()
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1

    --Kill the caster
    if caster:GetTeamNumber() ~= DOTA_TEAM_BADGUYS then
        caster:Kill(ability, caster)
    end
end