require("abilities/ability_generic")

function AddSummonBuff(key)
    local caster = key.caster
    local ability = key.ability
    local ability_level = ability:GetLevel() - 1
    local bonus_hp = ability:GetLevelSpecialValueFor("hp_bonus_per_str", ability_level) / 100
    local bonus_damage = ability:GetLevelSpecialValueFor("damage_bonus_per_int", ability_level) / 100
    local bonus_armor = ability:GetLevelSpecialValueFor("armor_bonus_per_agi", ability_level)
    local bonus_speed = ability:GetLevelSpecialValueFor("speed_bonus_per_agi", ability_level)
    local model_scale = ability:GetLevelSpecialValueFor("model_scale_per_att", ability_level) / 100

    local owner = caster.owner

    --僵尸小熊重置原始属性
    if caster.buffed == true then
        caster:SetModelScale(caster.scale)
        --print("health"..caster.health)
        caster:SetBaseDamageMin(caster.initMinDamage)
        --print("minDamage"..caster.initMinDamage)
        caster:SetBaseDamageMax(caster.initMaxDamage)
        --print("maxDamage"..caster.initMaxDamage)
        caster:SetPhysicalArmorBaseValue(caster.armor)
        --print("armor"..caster.armor)
        caster:RemoveModifierByName("modifier_speed_bonus")
    end

    local owner_str = owner:GetStrength()
    local owner_agi = owner:GetAgility()
    local owner_int = owner:GetIntellect()

    if string.match(caster:GetUnitName(), "npc_dota_warlock_golem") then
        owner_str = owner_str / 3
        owner_agi = owner_agi / 3
        owner_int = owner_int / 3
    elseif string.match(caster:GetUnitName(), "npc_dota_warlock_golem") then
    end

    --体型
    local att_sum = owner_str + owner_agi + owner_int
    local scale = caster:GetModelScale()
    caster:SetModelScale(scale * math.log(3 + att_sum * model_scale))
    --攻击力
    local initMinDamage = caster:GetBaseDamageMin()
    local initMaxDamage = caster:GetBaseDamageMax()
    local minDamage = initMinDamage * (1 + owner_int * bonus_damage)
    local maxDamage = initMaxDamage * (1 + owner_int * bonus_damage)
    caster:SetBaseDamageMin(minDamage)
    caster:SetBaseDamageMax(maxDamage)
    --护甲
    local armor = caster:GetPhysicalArmorBaseValue()
    local armor_bonus = owner_agi * bonus_armor
    caster:SetPhysicalArmorBaseValue(armor + armor_bonus)
    --攻速
    local speed = bonus_speed * owner_agi
    AddModifier(caster, caster, ability, "modifier_speed_bonus", nil)
    caster:SetModifierStackCount("modifier_speed_bonus", ability, speed)
    --血量
    local initHealth = caster:GetMaxHealth()
    if caster.buffed == true then
        local health = (1 + owner_str * bonus_hp) * caster.health
        caster:SetBaseMaxHealth(health)
    else
        local health = (1 + owner_str * bonus_hp) * initHealth
        caster:SetBaseMaxHealth(health)
    end

    local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

    if caster.buffed == nil then
        caster.buffed = true
        caster.scale = scale
        caster.initMinDamage = initMinDamage
        caster.initMaxDamage = initMaxDamage
        caster.armor = armor
        caster.health = initHealth
    end
end