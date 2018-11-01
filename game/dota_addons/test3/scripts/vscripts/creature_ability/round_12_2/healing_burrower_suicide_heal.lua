healing_burrower_suicide_heal = class({})
LinkLuaModifier( "modifier_healing_burrower_suicide_heal", "creature_ability/round_12_2/modifiers/modifier_healing_burrower_suicide_heal", LUA_MODIFIER_MOTION_NONE )

--------------------------------------------------------------

function healing_burrower_suicide_heal:GetIntrinsicModifierName()
	return "modifier_healing_burrower_suicide_heal"
end

--------------------------------------------------------------

function healing_burrower_suicide_heal:OnSpellStart()
	if IsServer() then
		self:GetCaster():ForceKill( false )
	end
end

--------------------------------------------------------------