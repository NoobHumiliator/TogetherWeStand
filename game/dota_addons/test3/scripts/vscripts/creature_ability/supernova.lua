function LinkToCaster( keys )  --向施法者连一条输血线
	local target=keys.target
	local caster=keys.caster

	local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
    target.bloodLinkParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(target.BloodLinkParticle, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true)
    ability:ApplyDataDrivenModifier(target, caster, "modifier_supernova_buff_invulnerable", {})
end



function OnDestroyEgg( keys )  --取消血线，移除BUFF
	local target=keys.target
	local caster=keys.caster

	caster:RemoveModifierByNameAndCaster("modifier_supernova_buff_invulnerable", target)
    ParticleManager:DestroyParticle(target.BloodLinkParticle,false)
    ParticleManager:ReleaseParticleIndex(target.BloodLinkParticle)

end