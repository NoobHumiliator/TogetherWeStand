item_carapace_of_qaldin = class({})
LinkLuaModifier("modifier_item_carapace_of_qaldin", "item_ability/modifier/modifier_item_carapace_of_qaldin", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function item_carapace_of_qaldin:GetIntrinsicModifierName()
    return "modifier_item_carapace_of_qaldin"
end