item_precious_egg = class({})
LinkLuaModifier("modifier_item_precious_egg", "item_ability/modifier/modifier_item_precious_egg", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_precious_egg:GetIntrinsicModifierName()
    return "modifier_item_precious_egg"
end