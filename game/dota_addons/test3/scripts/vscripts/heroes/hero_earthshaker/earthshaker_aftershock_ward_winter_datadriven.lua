
earthshaker_aftershock_ward_winter_datadriven = class({})
LinkLuaModifier( "modifier_earthshaker_aftershock_ward_winter", "heroes/hero_earthshaker/modifier_earthshaker_aftershock_ward_winter", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_ward_earthshaker_aftershock", "heroes/hero_earthshaker/modifier_ward_earthshaker_aftershock", LUA_MODIFIER_MOTION_NONE )


-----------------------------------------------------------------------------------------

function earthshaker_aftershock_ward_winter_datadriven:ProcsMagicStick()
	return false
end

--------------------------------------------------------------------------------

function earthshaker_aftershock_ward_winter_datadriven:OnSpellStart()
	if IsServer() then
		if self:GetCaster() == nil or self:GetCaster():IsNull() then
			return
		end
		local hWard = CreateUnitByName( "npc_dota_earthshaker_aftershock_ward_winter", self:GetCursorPosition(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber() )
		if hWard ~= nil then
			local flDuration = self:GetSpecialValueFor( "ward_duration" )

			local kv =
			{
				duration = flDuration,
			}
			self:GetCaster().hWard = hWard
			hWard:AddNewModifier( self:GetCaster(), self, "modifier_earthshaker_aftershock_ward_winter", kv )
			hWard:AddNewModifier( self:GetCaster(), self, "modifier_kill", {duration = flDuration} )
			EmitSoundOn( "Hero_EarthShaker.Totem.TI6.Layer", hWard )
		end
	end
end