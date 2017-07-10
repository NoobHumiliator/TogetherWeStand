function InitCountDown( event )

    local caster = event.caster
	local ability = event.ability
    local life_time = ability:GetLevelSpecialValueFor("init_time", ability:GetLevel() - 1)
	local countDownParticle= ParticleManager:CreateParticle("particles/hw_fx/candy_carrying_stack.vpcf",PATTACH_OVERHEAD_FOLLOW,caster)
    caster.countDownParticle=countDownParticle
    caster.life_time=life_time
    
    if caster.life_time<10 and caster.life_time>=0 then
      ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(0,caster.life_time,0))
    else
      ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(math.floor(caster.life_time/10),caster.life_time-math.floor(caster.life_time/10)*10,0))
    end
end

function Onthink( event )

    local caster = event.caster
	local ability = event.ability
  
    caster.life_time=caster.life_time-1
    if caster.life_time<0 then 
        caster:ForceKill(true)
        return
    end
       
	if caster.life_time<10 and caster.life_time>=0 then
	  ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(0,caster.life_time,0))
	else
	  ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(math.floor(caster.life_time/10),caster.life_time-math.floor(caster.life_time/10)*10,0))
	end
end
