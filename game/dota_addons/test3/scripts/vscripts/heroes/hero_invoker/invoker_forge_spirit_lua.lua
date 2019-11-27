invoker_forge_spirit_lua = class({})
LinkLuaModifier("modifier_invoker_forge_spirit_lua", "heroes/hero_invoker/modifier_invoker_forge_spirit_lua", LUA_MODIFIER_MOTION_NONE)
--------------------------------------------------------------------------------
-- Ability Start
function invoker_forge_spirit_lua:OnSpellStart()
    if not IsServer() then return end
    -- unit identifier
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    -- load data
    local damage = self:GetSpecialValueFor("spirit_damage")
    local health = self:GetSpecialValueFor("spirit_hp")
    local mana = self:GetSpecialValueFor("spirit_mana")
    local duration = self:GetSpecialValueFor("spirit_duration")

    local spirit_count = 1
    local talent = caster:FindAbilityByName("special_bonus_unique_invoker_1")
    if talent and talent:GetLevel() > 0 then
        spirit_count = talent:GetSpecialValueFor("value")
    end

    if self.forged_spirits then
        for _, unit in pairs(self.forged_spirits) do
            if unit and unit:IsAlive() then
                unit:ForceKill(true)
            end
        end
    end

    self.forged_spirits = {}

    for i = 1, spirit_count do
        local forged_spirit = CreateUnitByName("npc_dota_creature_invoker_forged_spirit", caster:GetAbsOrigin() + RandomVector(100), false, caster, caster, caster:GetTeamNumber())

        for i = 0, 30 - 1 do
            local hAbility = forged_spirit:FindAbilityByName("forged_spirit_melting_strike")
            while hAbility and hAbility:CanAbilityBeUpgraded() == ABILITY_CAN_BE_UPGRADED do
                hAbility:UpgradeAbility(true)
            end
        end

        forged_spirit:AddNewModifier(caster, self, "modifier_kill", { duration = duration })
        forged_spirit:SetControllableByPlayer(caster:GetPlayerID(), true)

        forged_spirit:SetBaseMaxHealth(health)
        forged_spirit:SetMaxMana(mana)
        forged_spirit:SetBaseDamageMin(damage)
        forged_spirit:SetBaseDamageMax(damage)

        FindClearSpaceForUnit(forged_spirit, forged_spirit:GetOrigin(), false)
        forged_spirit:SetAngles(0, 0, 0)

        forged_spirit:AddNewModifier(caster, self, "modifier_invoker_forge_spirit_lua", { duration = duration })

        table.insert(self.forged_spirits, forged_spirit)
    end
    local sound_cast = "Hero_Invoker.ForgeSpirit"
    EmitSoundOn(sound_cast, self:GetCaster())
end

function invoker_forge_spirit_lua:GetCastAnimation()
    return ACT_DOTA_CAST_FORGE_SPIRIT
end