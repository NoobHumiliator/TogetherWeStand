LinkLuaModifier("modifier_health_damage_buff", "creature_ability/round_faceless/modifier_health_damage_buff", LUA_MODIFIER_MOTION_NONE)

function InitDamageBuff(event)
    local caster = event.caster
    local ability = event.ability
    if caster:GetTeamNumber() == DOTA_TEAM_BADGUYS then
        caster:AddNewModifier(caster, ability, "modifier_health_damage_buff", {})
    elseif not GameRules:IsCheatMode() then
        caster:RemoveModifierByName("modifier_faceless_undie")
    end
end

function Onthink(event)

    local caster = event.caster
    local ability = event.ability

    if caster:GetHealth() < caster:GetMaxHealth() * 0.1 and not caster.life_time then  --符合条件开始倒计时
        InitCountDown(caster, ability)
        return
    end

    if caster:GetHealth() > caster:GetMaxHealth() * 0.1 and caster.life_time then  --不符合条件并且倒计时存在 停止倒计时
        DestoryCountDown(caster)
        return
    end


    if caster.life_time then  --如果倒计时存在，正常倒计时
        caster.life_time = caster.life_time - 1
        if caster.life_time < 0 then
            caster:ForceKill(true)
            return
        end

        if caster.life_time < 10 and caster.life_time >= 0 then
            ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(0, caster.life_time, 0))
        else
            ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(math.floor(caster.life_time / 10), caster.life_time - math.floor(caster.life_time / 10) * 10, 0))
        end
    end
end

function InitCountDown(caster, ability)

    local countDownParticle = ParticleManager:CreateParticle("particles/hw_fx/candy_carrying_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, caster)
    caster.countDownParticle = countDownParticle
    caster.life_time = 99
    --caster.modelScale=caster:GetModelScale()
    ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(9, 9, 0))  --这里要改时间
end

function DestoryCountDown(caster)
    ParticleManager:DestroyParticle(caster.countDownParticle, true)
    ParticleManager:ReleaseParticleIndex(caster.countDownParticle)
    caster.life_time = nil
end