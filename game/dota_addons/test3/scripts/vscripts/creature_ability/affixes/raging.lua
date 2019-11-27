require('libraries/notifications')
function CheckRaging(event)

    local caster = event.caster
    local ability = event.ability

    if caster:GetHealth() < caster:GetMaxHealth() * 0.3 and caster.raging_flag == nil then
        caster.raging_flag = true
        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
        ability:ApplyDataDrivenModifier(caster, caster, "modifier_raging_show", {})
        if caster.damageMultiple ~= nil and caster.damageMultiple > 0 then
            caster.damageMultiple = caster.damageMultiple * 2
        end
    end
end