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