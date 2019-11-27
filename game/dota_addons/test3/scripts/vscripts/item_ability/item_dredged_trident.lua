item_dredged_trident = class({})
LinkLuaModifier("modifier_item_dredged_trident", "item_ability/modifier/modifier_item_dredged_trident", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_dredged_trident:GetIntrinsicModifierName()
    return "modifier_item_dredged_trident"
end
