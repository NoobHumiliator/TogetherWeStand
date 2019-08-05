item_amorphotic_shell = class({})
LinkLuaModifier("modifier_item_amorphotic_shell", "item_ability/modifier/modifier_item_amorphotic_shell", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_amorphotic_shell:GetIntrinsicModifierName()
    return "modifier_item_amorphotic_shell"
end