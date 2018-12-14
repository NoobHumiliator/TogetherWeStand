
item_mage_shield_1 = class({})
LinkLuaModifier( "modifier_mage_shield_passive", "item_ability/modifier/modifier_mage_shield_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_mage_shield_active", "item_ability/modifier/modifier_mage_shield_active", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_mage_shield_1:OnSpellStart()
	if IsServer() then
		self.duration = self:GetSpecialValueFor( "duration" )
		print(self.duration)
		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_mage_shield_active", { duration = self.duration } )
		EmitSoundOn( "DOTA_Item.LinkensSphere.Activate", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function item_mage_shield_1:GetIntrinsicModifierName()
	return "modifier_mage_shield_passive"
end
