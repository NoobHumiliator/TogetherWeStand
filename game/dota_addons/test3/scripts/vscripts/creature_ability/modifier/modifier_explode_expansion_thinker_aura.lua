modifier_explode_expansion_thinker_aura = class({})

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:OnCreated( kv )
	self.init_radius = self:GetAbility():GetSpecialValueFor( "init_radius" )
	self.radius_increase = self:GetAbility():GetSpecialValueFor( "radius_increase" )
	if IsServer() then
		self:StartIntervalThink( 0.1 )
		self.radius=self.init_radius
	end
end

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:OnIntervalThink()   --扩大范围
	if IsServer() then
		self.radius=self.radius+self.radius_increase
		ParticleManager:SetParticleControl(self.nFXIndex, 1, Vector(self.radius,1,1))
	end
end
--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:GetAuraRadius()
	print("self.radius"..self.radius)
	return self.radius
end

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:IsAura()
	return true
end
-------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:GetModifierAura()
	return "modifier_explode_expansion_thinker_aura_effect"
end

-------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:GetAuraSearchType()   --影响所有单位
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC+ DOTA_UNIT_TARGET_CREEP
end

-------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:GetAuraSearchFlags()  --影响魔免单位
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES          
end

--------------------------------------------------------------------------------
