lycan_boss_shapeshift = class({})
LinkLuaModifier( "modifier_lycan_boss_shapeshift_transform", "creature_ability/modifier/modifier_lycan_boss_shapeshift_transform", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_lycan_boss_shapeshift", "creature_ability/modifier/modifier_lycan_boss_shapeshift", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function lycan_boss_shapeshift:OnAbilityPhaseStart()
	if IsServer() then
		EmitSoundOn( "lycan_lycan_ability_shapeshift_06", self:GetCaster() )
	end
	return true
end

--------------------------------------------------------------------------------

function lycan_boss_shapeshift:OnSpellStart()
	if IsServer() then
		Notifications:BossAbilityDBM("lycan_boss_shapeshift")
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_lycan_boss_shapeshift_transform", { duration = self:GetSpecialValueFor( "transformation_time" ) } )
	end
end