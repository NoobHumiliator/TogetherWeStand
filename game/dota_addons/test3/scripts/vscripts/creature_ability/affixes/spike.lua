require( "util" )

function ApplySpike(event)

	local caster = event.caster
    local time =GameRules:GetGameTime()
    local ability = event.ability
    local interval= ability:GetLevelSpecialValueFor("active_interval", (ability:GetLevel() - 1))
    local duration= ability:GetLevelSpecialValueFor("warning_duration", (ability:GetLevel() - 1))

    if (time%interval)<(duration-0.5) and  not caster:HasModifier("modifier_affixes_spike_warning") then
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_affixes_spike_warning", { duration = duration })        
    end
end

function TakeDamage(event)
    local damage = event.Damage
   	local caster = event.caster
	local ability = event.ability
    local attacker = event.attacker
    
    --反伤不受怪物伤害增幅影响
    if attacker.damageMultiple~=nil then
        damage=damage/attacker.damageMultiple
    end
    
	local damage_table = {}
	damage_table.attacker = caster
	damage_table.victim = attacker
	damage_table.damage_type = DAMAGE_TYPE_PURE
	damage_table.ability = ability
	damage_table.damage = damage
	damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
	ApplyDamage(damage_table)
end