LinkLuaModifier("modifier_special_bonus_unique_invoker_5", "talent_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_special_bonus_unique_lina_2", "talent_modifiers", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_special_bonus_unique_queen_of_pain", "talent_modifiers", LUA_MODIFIER_MOTION_NONE)

mapTalentModifier = {
    --special_bonus_unique_invoker_4 = true, -- 毁天灭地
    special_bonus_unique_invoker_5 = true, -- 灵动迅捷
    special_bonus_unique_lina_2 = true, -- 炽魂
    special_bonus_unique_queen_of_pain = true, -- 650 范围型 暗影突袭
}

-- modifier_special_bonus_unique_invoker_4 = class({})

-- function modifier_special_bonus_unique_invoker_4:IsHidden()
--     return true
-- end

-- function modifier_special_bonus_unique_invoker_4:IsPurgable()
--     return false
-- end

-- function modifier_special_bonus_unique_invoker_4:RemoveOnDeath()
--     return false
-- end


modifier_special_bonus_unique_invoker_5 = class({})

function modifier_special_bonus_unique_invoker_5:IsHidden()
    return true
end

function modifier_special_bonus_unique_invoker_5:IsPurgable()
    return false
end

function modifier_special_bonus_unique_invoker_5:RemoveOnDeath()
    return false
end


modifier_special_bonus_unique_lina_2 = class({})

function modifier_special_bonus_unique_lina_2:IsHidden()
    return true
end

function modifier_special_bonus_unique_lina_2:IsPurgable()
    return false
end

function modifier_special_bonus_unique_lina_2:RemoveOnDeath()
    return false
end


modifier_special_bonus_unique_queen_of_pain = class({})

function modifier_special_bonus_unique_queen_of_pain:IsHidden()
    return true
end

function modifier_special_bonus_unique_queen_of_pain:IsPurgable()
    return false
end

function modifier_special_bonus_unique_queen_of_pain:RemoveOnDeath()
    return false
end