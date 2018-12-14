boss_sand_king_passive = class({})
LinkLuaModifier( "modifier_boss_sand_king_passive", "creature_ability/round_sandking/modifiers/modifier_boss_sand_king_passive", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_boss_sand_king_caustic_finale", "creature_ability/round_sandking/modifiers/modifier_boss_sand_king_caustic_finale", LUA_MODIFIER_MOTION_NONE )



-----------------------------------------------------------------------------------------

function boss_sand_king_passive:GetIntrinsicModifierName()
	return "modifier_boss_sand_king_passive"
end

-----------------------------------------------------------------------------------------

function boss_sand_king_passive:OnOwnerDied()
	if self:GetCaster().vFissures then
	  for _, hFissure in pairs(self:GetCaster().vFissures) do
	      if hFissure:IsAlive() then
	    	hFissure:ForceKill(true)
	    	ParticleManager:DestroyParticle(hFissure.nFXIndex, true)
	      end
	   end
	end
end

-----------------------------------------------------------------------------------------
