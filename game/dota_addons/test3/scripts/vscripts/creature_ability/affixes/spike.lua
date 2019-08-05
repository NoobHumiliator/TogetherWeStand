require("util")

function ApplySpike(event)

    local caster = event.caster
    local time = GameRules:GetGameTime()
    local ability = event.ability
    local interval = ability:GetLevelSpecialValueFor("active_interval", (ability:GetLevel() - 1))
    local duration = ability:GetLevelSpecialValueFor("warning_duration", (ability:GetLevel() - 1))

    if (time % interval) < (duration - 0.5) and not caster:HasModifier("modifier_affixes_spike_warning") then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_affixes_spike_warning", { duration = duration })
    end
end

function TakeDamage(event)
    local damage = event.Damage
    local caster = event.caster
    local ability = event.ability
    local attacker = event.attacker

    local re_table = {
        item_blade_mail = true,
        nyx_assassin_spiked_carapace = true,
        spectre_dispersion = true,
        spectre_dispersion_lua = true,
        creature_spectre_dispersion = true,
        affixes_ability_spike = true,
        creature_nyx_spike = true,
        frostivus2018_spectre_active_dispersion = true,
    }
	
	if attacker:GetTeamNumber() == caster:GetTeamNumber() or ability and re_table[ability:GetAbilityName()] then
		return
	end

    --反伤不受怪物伤害增幅影响
    if attacker.damageMultiple ~= nil then
        damage = damage / attacker.damageMultiple
    end

    local damage_table = {}
    damage_table.attacker = caster
    damage_table.victim = attacker
    damage_table.damage_type = DAMAGE_TYPE_PURE
    damage_table.ability = thisEntity:GetAbility()
    damage_table.damage = damage
    damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
    ApplyDamage(damage_table)
end