-- Created by Elfansoer
--[[Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
--------------------------------------------------------------------------------
ogre_magi_multicast_lua = class({})
LinkLuaModifier("modifier_ogre_magi_item_multicast_lua", "heroes/hero_ogre_magi/modifier_ogre_magi_item_multicast_lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_ogre_magi_item_multicast_lua_proc", "heroes/hero_ogre_magi/modifier_ogre_magi_item_multicast_lua_proc", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Passive Modifier
function ogre_magi_multicast_lua:GetIntrinsicModifierName()
    return "modifier_ogre_magi_item_multicast_lua"
end