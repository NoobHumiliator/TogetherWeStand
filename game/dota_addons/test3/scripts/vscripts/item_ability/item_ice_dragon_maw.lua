item_ice_dragon_maw = class({})
LinkLuaModifier("modifier_item_ice_dragon_maw", "item_ability/modifier/modifier_item_ice_dragon_maw", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_ice_dragon_maw:GetIntrinsicModifierName()
    return "modifier_item_ice_dragon_maw"
end