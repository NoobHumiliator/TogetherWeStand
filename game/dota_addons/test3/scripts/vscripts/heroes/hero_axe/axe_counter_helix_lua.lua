axe_counter_helix_lua = class({})
LinkLuaModifier("modifier_axe_counter_helix_lua", "heroes/hero_axe/modifier_axe_counter_helix_lua", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
function axe_counter_helix_lua:GetIntrinsicModifierName()
    return "modifier_axe_counter_helix_lua"
end