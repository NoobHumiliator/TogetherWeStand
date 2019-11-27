item_unhallowed_icon = class({})
LinkLuaModifier("modifier_item_unhallowed_icon", "item_ability/modifier/modifier_item_unhallowed_icon", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_item_unhallowed_icon_effect", "item_ability/modifier/modifier_item_unhallowed_icon_effect", LUA_MODIFIER_MOTION_NONE)


--------------------------------------------------------------------------------
function item_unhallowed_icon:GetIntrinsicModifierName()
    return "modifier_item_unhallowed_icon"
end