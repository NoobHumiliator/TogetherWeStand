require("abilities/ability_generic")
require('quest_system')

function water_grow(keys)
    local caster = keys.caster
    local ability = keys.ability
    if caster:GetContext("big_scale") == nil then    --dot计数器初始化
        caster:SetContextNum("big_scale", 1, 0)
    end
    caster:SetContextNum("big_scale", caster:GetContext("big_scale") + 0.05, 0)
    caster:SetModelScale(caster:GetContext("big_scale"))
    local rate = (caster:GetHealth() / caster:GetMaxHealth())
    local flDHPadjust = GameRules:GetGameModeEntity().CHoldoutGameMode.flDHPadjust  --难度修正
    local bonus_health = ability:GetSpecialValueFor("bonus_health") * flDHPadjust --获取新增的生命值
    caster:SetBaseMaxHealth(caster:GetMaxHealth() + bonus_health)
    caster:SetHealth(math.ceil(rate * caster:GetMaxHealth()))
end

function water_fuse(keys)
    local caster = keys.caster
    local ability = keys.ability
    if caster:GetContext("big_scale") == nil then    --长大计数器
        caster:SetContextNum("big_scale", 1, 0)
    end
    local rate = (caster:GetHealth() / caster:GetMaxHealth())
    local flDHPadjust = GameRules:GetGameModeEntity().CHoldoutGameMode.flDHPadjust  --难度修正
    local bonus_health = ability:GetSpecialValueFor("bonus_health") * flDHPadjust --获取新增的生命值
    caster:SetBaseMaxHealth(caster:GetMaxHealth() + bonus_health)
    caster:SetHealth(math.ceil(rate * caster:GetMaxHealth()))
    caster:SetContextNum("big_scale", caster:GetContext("big_scale") + 0.3, 0)
    caster:SetModelScale(caster:GetContext("big_scale"))
    local c_team = caster:GetTeam()
    local radius = 210
    local targets = FindUnitsInRadius(c_team, caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    for i, unit in pairs(targets) do
        unitName = unit:GetUnitName()
        if unit:GetUnitName() == ("npc_majia_water_1") then
            unit:ForceKill(true)
        end
    end
    local targets = FindUnitsInRadius(c_team, caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
    for i, unit in pairs(targets) do
        unitName = unit:GetUnitName()
        if unit:GetUnitName() == ("npc_majia_water_1") then
            unit:ForceKill(true)
        end
    end
end

function water_remove_self(keys)
    local caster = keys.caster
    caster.removedByMech = true
    caster:RemoveAbility('water_die')
    if caster:FindAbilityByName("generic_gold_bag_fountain_500") then
        caster:RemoveAbility('generic_gold_bag_fountain_500')
    end
    if caster:FindAbilityByName("generic_gold_bag_fountain_200") then
        caster:RemoveAbility('generic_gold_bag_fountain_200')
    end
    if caster:FindAbilityByName("generic_gold_bag_fountain_100") then
        caster:RemoveAbility('generic_gold_bag_fountain_100')
    end
    if caster:FindAbilityByName("generic_gold_bag_fountain_50") then
        caster:RemoveAbility('generic_gold_bag_fountain_50')
    end
    local casterOrigin = caster:GetOrigin()
    caster.removedByMech = true
    caster:SetOrigin(casterOrigin - Vector(0, 0, 1500))
    caster:ForceKill(true)
    GameRules:SendCustomMessage("#envolveto3_dbm", 0, 0)
end