
modifier_boss_ancient_apparition_frozen = class({})

-----------------------------------------------------------------------------
function modifier_boss_ancient_apparition_frozen:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}
	return state
end

-----------------------------------------------------------------------------
function modifier_boss_ancient_apparition_frozen:OnCreated()
	 if IsServer() then
          self.particleIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_crystalmaiden/maiden_frostbite_buff.vpcf", PATTACH_ABSORIGIN  , self:GetParent())
	 end
end
----------------------------------------------------------------------------
function modifier_boss_ancient_apparition_frozen:OnDestroy()

	 if IsServer() then
       ParticleManager:DestroyParticle(self.particleIndex, true)
       ParticleManager:ReleaseParticleIndex(self.particleIndex)
	 end

end
----------------------------------------------------------------------------