--[[	Author: Noya
	Date: 18.01.2015.
	Kills a target, gives Mana to the caster according to the sacrificed target current Health
	Also gives split XP to all heroes in radius
]]
function DarkRitual(params)
    local caster = params.caster
    local target = params.target
    local ability = params.ability

    -- Mana to give
    local target_health = target:GetHealth()
    local rate = ability:GetLevelSpecialValueFor("health_conversion", ability:GetLevel() - 1) * 0.01
    local mana_gain = target_health * rate

    local exp = target:GetDeathXP()

    local heroes = FindUnitsInRadius(
        target:GetTeamNumber(), -- int, your team number
        target:GetOrigin(), -- point, center point
        nil, -- handle, cacheUnit. (not known)
        1500, -- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_FRIENDLY, -- int, team filter
        DOTA_UNIT_TARGET_HERO, -- int, type filter
        DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, -- int, flag filter
        FIND_ANY_ORDER, -- int, order filter
        false	-- bool, can grow cache
        )
    for _, hero in pairs(heroes) do
        if hero:IsRealHero() then
            print("AddExperience: ".. hero:GetUnitName())
            hero:AddExperience(exp / #heroes, DOTA_ModifyXP_CreepKill, false, true)
        end
    end

    caster:GiveMana(mana_gain)

    -- Purple particle with eye
    local particleName = "particles/msg_fx/msg_xp.vpcf"
    local particle = ParticleManager:CreateParticle(particleName, PATTACH_OVERHEAD_FOLLOW, target)

    local digits = 0
    if mana_gain ~= nil then
        digits = #tostring(mana_gain)
    end

    ParticleManager:SetParticleControl(particle, 1, Vector(9, mana_gain, 6))
    ParticleManager:SetParticleControl(particle, 2, Vector(1, digits + 1, 0))
    ParticleManager:SetParticleControl(particle, 3, Vector(170, 0, 250))

    -- Kill the target, ForceKill doesn't grant xp
    target:ForceKill(true)

end