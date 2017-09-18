
item_wand_of_the_brine = class({})
LinkLuaModifier( "modifier_item_wand_of_the_brine", "item_ability/modifier/modifier_item_wand_of_the_brine", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_item_wand_of_the_brine_bubble", "item_ability/modifier/modifier_item_wand_of_the_brine_bubble", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------------------------

function item_wand_of_the_brine:OnSpellStart()
	if IsServer() then
		self.bubble_duration = self:GetSpecialValueFor( "bubble_duration" )

		local hTarget = self:GetCursorTarget()
		hTarget:AddNewModifier( self:GetCaster(), self, "modifier_item_wand_of_the_brine_bubble", { duration = self.bubble_duration } )

		EmitSoundOn( "DOTA_Item.GhostScepter.Activate", self:GetCaster() )
	end
end

--------------------------------------------------------------------------------

function item_wand_of_the_brine:GetIntrinsicModifierName()
	return "modifier_item_wand_of_the_brine"
end

--------------------------------------------------------------------------------