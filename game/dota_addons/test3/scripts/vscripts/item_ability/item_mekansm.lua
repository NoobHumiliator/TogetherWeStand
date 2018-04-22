function Mekansm( keys )	
	local caster = keys.caster
	local ability = keys.ability
	local heal_amount = keys.heal_amount
	local heal_radius = keys.heal_radius
	local modifier_armor = keys.modifier_armor

	caster:EmitSound("DOTA_Item.Mekansm.Activate")
	ParticleManager:CreateParticle("particles/items2_fx/mekanism.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)

	local nearby_allied_units = FindUnitsInRadius(caster:GetTeam(), caster:GetAbsOrigin(), nil, heal_radius,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false)
		
	--Restore health and play a particle effect for every found ally.
	for i, nearby_ally in ipairs(nearby_allied_units) do
		if not nearby_ally:HasModifier("modifier_item_golden_mekansm_heal_armor") then
			nearby_ally:Heal(heal_amount, caster)
			nearby_ally:EmitSound("DOTA_Item.Mekansm.Target")
			local mekansm_target_pfx = ParticleManager:CreateParticle("particles/items2_fx/mekanism_recipient.vpcf", PATTACH_ABSORIGIN_FOLLOW, nearby_ally)
			ParticleManager:SetParticleControl(mekansm_target_pfx, 0, caster:GetAbsOrigin())
			ParticleManager:SetParticleControl(mekansm_target_pfx, 1, nearby_ally:GetAbsOrigin())

			ability:ApplyDataDrivenModifier(caster, nearby_ally, modifier_armor, nil)
	    end
	end
end