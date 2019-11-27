-- Created by Elfansoer
--[[Ability checklist (erase if done/checked):
- Scepter Upgrade
- Break behavior
- Linken/Reflect behavior
- Spell Immune/Invulnerable/Invisible behavior
- Illusion behavior
- Stolen behavior
]]
LinkLuaModifier("modifier_shredder_chakram_lua_debuff", "heroes/hero_shredder/modifier_shredder_chakram_lua_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shredder_chakram_lua_disarm", "heroes/hero_shredder/modifier_shredder_chakram_lua_disarm", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_shredder_chakram_lua_thinker", "heroes/hero_shredder/modifier_shredder_chakram_lua_thinker", LUA_MODIFIER_MOTION_NONE)

--------------------------------------------------------------------------------
-- Main ability
--------------------------------------------------------------------------------
shredder_chakram_lua = class({})

-- register here for easy copy on scepter ability
shredder_chakram_lua.sub_name = "shredder_return_chakram_lua"
shredder_chakram_lua.scepter = 0

--------------------------------------------------------------------------------
-- Custom KV
-- AOE Radius
function shredder_chakram_lua:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

--------------------------------------------------------------------------------
-- Ability Start
function shredder_chakram_lua:OnSpellStart()
    -- unit identifier
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    -- create thinker
    local thinker = CreateModifierThinker(
    caster, -- player source
    self, -- ability source
    "modifier_shredder_chakram_lua_thinker", -- modifier name
    {
        target_x = point.x,
        target_y = point.y,
        target_z = point.z,
        scepter = self.scepter,
    }, -- kv
    caster:GetOrigin(),
    caster:GetTeamNumber(),
    false
    )
    local modifier = thinker:FindModifierByName("modifier_shredder_chakram_lua_thinker")

    -- add return ability and swap
    local sub = caster:AddAbility(self.sub_name)
    sub:SetLevel(1)
    caster:SwapAbilities(
    self:GetAbilityName(),
    self.sub_name,
    false,
    true
    )

    -- register each other
    self.modifier = modifier
    self.sub = sub
    sub.modifier = modifier
    modifier.sub = sub

    -- play effects
    local sound_cast = "Hero_Shredder.Chakram.Cast"
    EmitSoundOn(sound_cast, caster)
end

function shredder_chakram_lua:OnUnStolen()
    if self.modifier and not self.modifier:IsNull() then
        -- return the chakram
        self.modifier:ReturnChakram()

        -- reset position
        self:GetCaster():SwapAbilities(
        self:GetAbilityName(),
        self.sub:GetAbilityName(),
        true,
        false
        )
    end
end

--------------------------------------------------------------------------------
-- Sub-ability
--------------------------------------------------------------------------------
shredder_return_chakram_lua = class({})

--------------------------------------------------------------------------------
-- Ability Start
function shredder_return_chakram_lua:OnSpellStart()
    if self.modifier and not self.modifier:IsNull() then
        self.modifier:ReturnChakram()
    end
end

--------------------------------------------------------------------------------
-- Scepter-ability
--------------------------------------------------------------------------------
shredder_chakram_2_lua = class(shredder_chakram_lua)
shredder_chakram_2_lua.sub_name = "shredder_return_chakram_2_lua"
shredder_chakram_2_lua.scepter = 1

shredder_return_chakram_2_lua = class(shredder_return_chakram_lua)