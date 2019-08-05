require("abilities/ability_generic")
require('quest_system')


function warlock_disappear( keys )
        local caster = keys.caster
        local casterOrigin=caster:GetOrigin()
        caster:SetOrigin(casterOrigin-Vector(0,0,1500))
        caster:ForceKill(true)
end

