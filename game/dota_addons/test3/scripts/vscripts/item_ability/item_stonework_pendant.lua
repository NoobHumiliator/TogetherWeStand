item_stonework_pendant = class({})
LinkLuaModifier("modifier_item_stonework_pendant", "item_ability/modifier/modifier_item_stonework_pendant", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_stonework_pendant:GetIntrinsicModifierName()
    return "modifier_item_stonework_pendant"
end