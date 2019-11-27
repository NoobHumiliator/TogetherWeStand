pugna_ward_winter_2018 = class({})
LinkLuaModifier("modifier_pugna_ward_winter_2018", "heroes/hero_pugna/modifier_pugna_ward_winter_2018", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_pugna_ward_winter_2018_effect", "heroes/hero_pugna/modifier_pugna_ward_winter_2018_effect", LUA_MODIFIER_MOTION_NONE)

-----------------------------------------------------------------------------------------
function pugna_ward_winter_2018:ProcsMagicStick()
    return false
end

--------------------------------------------------------------------------------
function pugna_ward_winter_2018:OnSpellStart()
    if IsServer() then
        if self:GetCaster() == nil or self:GetCaster():IsNull() then
            return
        end
        local hWard = CreateUnitByName("npc_dota_pugna_ward_winter_2018", self:GetCursorPosition(), true, self:GetCaster(), self:GetCaster(), self:GetCaster():GetTeamNumber())
        if hWard ~= nil then
            local flDuration = self:GetSpecialValueFor("ward_duration")
            local kv =             {
                duration = flDuration,
            }
            self:GetCaster().hWard = hWard
            hWard:AddNewModifier(self:GetCaster(), self, "modifier_pugna_ward_winter_2018", kv)
            hWard:AddNewModifier(self:GetCaster(), self, "modifier_kill", kv)

            --			local nWardFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_pugna/pugna_ward_ambient.vpcf", PATTACH_CUSTOMORIGIN, nil )
            --			ParticleManager:SetParticleControl( nWardFX, 0, self:GetCursorPosition() )
            --			ParticleManager:SetParticleControlEnt( nWardFX, 1, self:GetCaster(), flDuration, "attach_attack1", self:GetCaster():GetOrigin(), true )
            --			ParticleManager:SetParticleControl( nWardFX, 2, Vector( flDuration, flDuration, duration ) )
            --			ParticleManager:ReleaseParticleIndex( nWardFX )
            EmitSoundOn("Hero_Pugna.NetherWard", hWard)
        end
    end
end