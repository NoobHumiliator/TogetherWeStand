boss_sand_king_unburrow = class({})

--------------------------------------------------------------------
function boss_sand_king_unburrow:OnAbilityPhaseStart()
    if IsServer() then
        if self:GetCaster().nBurrowFXIndex == nil then
            return true
        end
        ParticleManager:DestroyParticle(self:GetCaster().nBurrowFXIndex, false)

        EmitSoundOn("Hero_NyxAssassin.Burrow.Out", self:GetCaster())
        local nFXIndex = ParticleManager:CreateParticle("particles/units/heroes/hero_nyx_assassin/nyx_assassin_burrow_exit.vpcf", PATTACH_CUSTOMORIGIN, nil)
        ParticleManager:SetParticleControl(nFXIndex, 0, self:GetCaster():GetOrigin())
    end
    return true
end

--------------------------------------------------------------------------------
function boss_sand_king_unburrow:GetPlaybackRateOverride()
    return 0.5
end

--------------------------------------------------------------------
function boss_sand_king_unburrow:OnSpellStart()
    if IsServer() then
        self:GetCaster():RemoveModifierByName("modifier_boss_sand_king_burrow")
    end
end