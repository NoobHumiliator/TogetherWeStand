require('libraries/notifications')
function Fortify(event)

    local caster = event.caster
    local ability = event.ability
    caster.fortify_flag = true


    if caster.damageMultiple ~= nil and caster.damageMultiple > 0 then

        caster.damageMultiple = caster.damageMultiple * 1.2

        local maxHealth = caster:GetMaxHealth()
        local newMaxHealth = maxHealth * 1.4
        caster:SetBaseMaxHealth(newMaxHealth)
        caster:SetMaxHealth(newMaxHealth)
        caster:SetHealth(newMaxHealth)
    end
end