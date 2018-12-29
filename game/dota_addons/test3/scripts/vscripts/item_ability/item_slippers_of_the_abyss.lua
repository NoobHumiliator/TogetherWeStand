
item_slippers_of_the_abyss = class({})
LinkLuaModifier( "modifier_item_slippers_of_the_abyss", "item_ability/modifier/modifier_item_slippers_of_the_abyss", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_slippers_of_the_abyss_sprint", "item_ability/modifier/modifier_item_slippers_of_the_abyss_sprint", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_slippers_of_the_abyss:GetIntrinsicModifierName()
	return "modifier_item_slippers_of_the_abyss"
end

--------------------------------------------------------------------------------

function item_slippers_of_the_abyss:OnSpellStart()
	if IsServer() then
		self.sprint_duration = self:GetSpecialValueFor( "sprint_duration" )

		self:GetCaster():AddNewModifier( self:GetCaster(), self, "modifier_item_slippers_of_the_abyss_sprint", { duration = self.sprint_duration } )

		EmitSoundOn( "Siltbreaker.Sprint", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------