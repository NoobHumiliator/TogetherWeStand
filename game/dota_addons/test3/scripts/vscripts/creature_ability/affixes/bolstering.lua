function AddBolsteringBuff( keys )

	local caster = keys.caster
	local ability = keys.ability
	local modifierName = "modifier_bolstering_stack"

   local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_sven/sven_spell_warcry.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster )
	ParticleManager:SetParticleControlEnt( nFXIndex, 2, caster, PATTACH_POINT_FOLLOW, "attach_head", caster:GetOrigin(), true )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
	
    local targets = FindUnitsInRadius( DOTA_TEAM_BADGUYS, caster:GetOrigin(), nil, 300, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	for _,target in pairs(targets) do
		if target:HasModifier( modifierName ) then
			local current_stack = target:GetModifierStackCount( modifierName, ability )
			current_stack=current_stack+1
			ability:ApplyDataDrivenModifier( caster, target, modifierName, {} )
			target:SetModifierStackCount( modifierName, ability, current_stack )
            local rate=target:GetHealth()/target:GetMaxHealth()
            local newMaxHealth=target.base_maxHealth*(1+0.2*current_stack)
            local newCurrentHealth=math.ceil(newMaxHealth*rate)
            if target.damageMultiple~=nil then
		     target.damageMultiple=target.base_damageMultiple*(1+0.2*current_stack)
		    end
		    target:SetBaseMaxHealth(newMaxHealth)
		    target:SetMaxHealth(newMaxHealth)
		    target:SetHealth(newCurrentHealth)
		else
			ability:ApplyDataDrivenModifier( target, target, modifierName, {} )
			target:SetModifierStackCount( modifierName, ability, 1 )

			local maxHealth=target:GetMaxHealth()
            target.base_maxHealth=maxHealth
			local rate=target:GetHealth()/target:GetMaxHealth()

		    if target.damageMultiple~=nil then
		     target.base_damageMultiple=target.damageMultiple
		     target.damageMultiple=target.damageMultiple*1.2
		    end
		    
		    local newMaxHealth=maxHealth*1.2
		    local newCurrentHealth=math.ceil(newMaxHealth*rate)
		    if newCurrentHealth<1 then
		       newCurrentHealth=1
		    end
			target:SetBaseMaxHealth(newMaxHealth)
		    target:SetMaxHealth(newMaxHealth)
		    target:SetHealth(newCurrentHealth)
		end
	end
	
end