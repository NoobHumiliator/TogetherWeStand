function Test(keys)
    local caster = keys.caster
    for i = 1, 10 do
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_ABSORIGIN, caster)
        ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin() + Vector(300 * i, 300 * i, 0))-- set position
        local position = caster:GetAbsOrigin() + Vector(300 * i, 300 * i, 0)
        print("x:" .. position.x .. " y:" .. position.y .. "hah" .. "z" .. position.z)
    end
end