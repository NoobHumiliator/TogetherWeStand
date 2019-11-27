storegga_rock_passive = class({})

LinkLuaModifier("modifier_storegga_rock_passive", "creature_ability/round_elder_titan/modifier_storegga_rock_passive", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
function storegga_rock_passive:GetIntrinsicModifierName()
    return "modifier_storegga_rock_passive"
end