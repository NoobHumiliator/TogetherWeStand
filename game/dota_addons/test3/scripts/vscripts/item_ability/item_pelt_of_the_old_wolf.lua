item_pelt_of_the_old_wolf = class({})
LinkLuaModifier("modifier_item_pelt_of_the_old_wolf", "item_ability/modifier/modifier_item_pelt_of_the_old_wolf", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_pelt_of_the_old_wolf:GetIntrinsicModifierName()
    return "modifier_item_pelt_of_the_old_wolf"
end