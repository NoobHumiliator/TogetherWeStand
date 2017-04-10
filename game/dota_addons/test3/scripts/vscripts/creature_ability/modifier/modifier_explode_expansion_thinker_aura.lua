modifier_explode_expansion_thinker_aura = class({})

--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:OnCreated( kv )
	self.init_radius = self:GetAbility():GetSpecialValueFor( "init_radius" )
	self.radius_increase = self:GetAbility():GetSpecialValueFor( "radius_increase" )
	if IsServer() then
		self:StartIntervalThink( 0.5 )
		self.radius=self.init_radius
		local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/faceless_void/faceless_void_mace_of_aeons/fv_chronosphere_aeons.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.init_radius, self.init_radius, self.init_radius) )
		ParticleManager:SetParticleControl( nFXIndex, 4, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 6, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 10, self:GetParent():GetOrigin() )
		self.nFXIndex=nFXIndex
	end
end
--------------------------------------------------------------------------------
function modifier_explode_expansion_thinker_aura:CheckState()
	local state = {
		[MODIFIER_STATE_PROVIDES_VISION] = true
	}
	return state
end
--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:OnIntervalThink()   --扩大范围
	if IsServer() then
		self.radius=self.radius+self.radius_increase

	    local nFXIndex = ParticleManager:CreateParticle( "particles/econ/items/faceless_void/faceless_void_mace_of_aeons/fv_chronosphere_aeons.vpcf", PATTACH_ABSORIGIN, self:GetParent() )
		ParticleManager:SetParticleControl( nFXIndex, 0, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( self.radius, self.radius, self.radius) )
		ParticleManager:SetParticleControl( nFXIndex, 4, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 6, self:GetParent():GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 10, self:GetParent():GetOrigin() )
        ParticleManager:DestroyParticle(self.nFXIndex,false)
        ParticleManager:ReleaseParticleIndex(self.nFXIndex)
        self.nFXIndex=nFXIndex

	end
end
--------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:GetAuraRadius()
	--print("self.radius"..self.radius)
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
	return DOTA_UNIT_TARGET_ALL
end

-------------------------------------------------------------------------------

function modifier_explode_expansion_thinker_aura:GetAuraSearchFlags()  --影响魔免单位
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES          
end

--------------------------------------------------------------------------------
