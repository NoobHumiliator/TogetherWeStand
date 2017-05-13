modifier_explode_expansion_ally_aura = class({})

--------------------------------------------------------------------------------

function modifier_explode_expansion_ally_aura:OnCreated( kv )
	self.init_radius = self:GetAbility():GetSpecialValueFor( "init_radius" )
	self.radius_increase = self:GetAbility():GetSpecialValueFor( "radius_increase" )
	if IsServer() then
		self:StartIntervalThink( 0.5 )
		self.radius=self.init_radius
	end
end
--------------------------------------------------------------------------------

function modifier_explode_expansion_ally_aura:GetAuraRadius()
	return (self.radius-180)
end
--------------------------------------------------------------------------------
function modifier_explode_expansion_ally_aura:OnIntervalThink()   --扩大范围
	if IsServer() then
		self.radius=self.radius+self.radius_increase
	end
end
--------------------------------------------------------------------------------

function modifier_explode_expansion_ally_aura:IsAura()
	return true
end
-------------------------------------------------------------------------------

function modifier_explode_expansion_ally_aura:GetModifierAura()
	return "modifier_explode_expansion_ally_aura_effect"
end

-------------------------------------------------------------------------------

function modifier_explode_expansion_ally_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

--------------------------------------------------------------------------------

function modifier_explode_expansion_ally_aura:GetAuraSearchType()   --影响所有单位
	return DOTA_UNIT_TARGET_ALL
end

-------------------------------------------------------------------------------

function modifier_explode_expansion_ally_aura:GetAuraSearchFlags()  --影响魔免单位
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE        
end

--------------------------------------------------------------------------------
