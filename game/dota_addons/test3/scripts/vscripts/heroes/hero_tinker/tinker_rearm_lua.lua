tinker_rearm_lua = class({})

function tinker_rearm_lua:GetCastAnimation()
	return ACT_DOTA_TINKER_REARM1
end

--------------------------------------------------------------------------------
-- Ability Start
function tinker_rearm_lua:OnSpellStart()
    -- effects
    local sound_cast = "Hero_Tinker.Rearm"
    EmitSoundOn(sound_cast, self:GetCaster())
    -- effects
    self:PlayEffects()

    local caster = self:GetCaster()

	caster:RemoveModifierByName("modifier_slark_shadow_dance")
    caster:RemoveModifierByName("modifier_abaddon_borrowed_time")
    caster:RemoveModifierByName("modifier_oracle_false_promise_timer")
    caster:RemoveModifierByName("modifier_dazzle_shallow_grave")
    caster:RemoveModifierByName("modifier_juggernaut_omnislash")
    caster:RemoveModifierByName("modifier_phantom_assassin_blur_active")
    caster:RemoveModifierByName("modifier_ember_spirit_fire_remnant")
end

--------------------------------------------------------------------------------
-- Ability Channeling
function tinker_rearm_lua:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()

    if bInterrupted then return end

    -- find all refreshable abilities
    for i = 0, caster:GetAbilityCount() - 1 do
        local ability = caster:GetAbilityByIndex(i)
        if ability and ability:GetAbilityType() ~= DOTA_ABILITY_TYPE_ATTRIBUTES and not self:IsAbilityException(ability) then
            ability:RefreshCharges()
            ability:EndCooldown()
        end
    end

    -- find all refreshable items
    for i = 0, 8 do
        local item = caster:GetItemInSlot(i)
        if item then
            local pass = false
            if item:GetPurchaser() == caster and not self:IsItemException(item) then
                pass = true
            end

            if pass then
                item:EndCooldown()
            end
        end
    end

end

--------------------------------------------------------------------------------
-- Helper
function tinker_rearm_lua:IsItemException(item)
    return self.ItemException[item:GetName()]
end
tinker_rearm_lua.ItemException = {
    ["item_aeon_disk"] = true,
    ["item_arcane_boots"] = true,
    ["item_black_king_bar"] = true,
    ["item_hand_of_midas"] = true,
    ["item_helm_of_the_dominator"] = true,
    ["item_meteor_hammer"] = true,
    --["item_necronomicon"] = true,
    --["item_necronomicon_2"] = true,
    --["item_necronomicon_3"] = true,
    ["item_refresher"] = true,
    ["item_refresher_shard"] = true,
    ["item_pipe"] = true,
    ["item_guardian_greaves"] = true,
    ["item_skysong_blade"] = true,
    ["item_fallen_sword"] = true,
    ["item_arcane_boots2"] = true,
    ["item_tome_of_knowledge"] = true,
}

function tinker_rearm_lua:IsAbilityException(ability)
    return self.AbilityException[ability:GetAbilityName()]
end
tinker_rearm_lua.AbilityException = {
    ["phoenix_supernova"] = true,
    ["skeleton_king_reincarnation"] = true,
    ["undying_tombstone"] = true,
    ["self_undying_tombstone"] = true,
    ["arc_warden_tempest_double"] = true,
    ["juggernaut_healing_ward"] = true,
    ["dark_seer_wall_of_replica_nb2017"] = true,
}

--------------------------------------------------------------------------------
-- Effects
function tinker_rearm_lua:PlayEffects()
    -- Get Resources
    local particle_cast = "particles/units/heroes/hero_tinker/tinker_rearm.vpcf"

    -- Create Particle
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self:GetCaster())
    ParticleManager:ReleaseParticleIndex(effect_cast)
end