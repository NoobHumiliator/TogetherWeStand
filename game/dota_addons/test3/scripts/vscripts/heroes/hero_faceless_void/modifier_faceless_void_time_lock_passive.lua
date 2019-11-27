if modifier_faceless_void_time_lock_passive == nil then modifier_faceless_void_time_lock_passive = class({}) end
function modifier_faceless_void_time_lock_passive:IsPurgable()            return false end
function modifier_faceless_void_time_lock_passive:IsDebuff()            return false end
function modifier_faceless_void_time_lock_passive:IsHidden()            return true end

function modifier_faceless_void_time_lock_passive:DeclareFunctions()
    local funcs = { MODIFIER_EVENT_ON_ATTACK_LANDED }
    return funcs
end

function modifier_faceless_void_time_lock_passive:OnCreated()
    if IsServer() then
        self:GetParent().bCanTriggerLock = true
    end
end



function modifier_faceless_void_time_lock_passive:OnAttackLanded(keys)
    if IsServer() then
		local owner = self:GetParent()
		
        -- If this attack was not performed by the modifier's owner, do nothing
        if owner ~= keys.attacker then
            return end
        -- 防止死循环
        if not owner.bCanTriggerLock then
            return
        end

        -- If this is an illusion, do nothing
        if owner:IsIllusion() then
            return end

        if owner:IsStunned() then
            return end

        -- Else, keep going
        local target = keys.target

        if not target:IsNull() and target:IsAlive() then
            self.bonus_damage = self:GetAbility():GetSpecialValueFor("bonus_damage")
            self.chance_pct = self:GetAbility():GetSpecialValueFor("chance_pct")
            self.chance_pct = self:GetAbility():GetSpecialValueFor("chance_pct")

            print(self.bonus_damage .. "twf" .. self.chance_pct)
            -- If the target is a hero or creep, increase this modifier's stack count
            if RandomFloat(0, 1) < (self.chance_pct / 100) then

                target:AddNewModifier(owner, self:GetAbility(), "modifier_stunned", { duration = 0.5 })

                --避免进入死循环
                owner.bCanTriggerLock = false
                owner:PerformAttack(target, true, true, true, false, false, false, false)
                owner.bCanTriggerLock = true

                local lock_pfx = ParticleManager:CreateParticle("particles/tws_custom/faceless_void_time_lock_bash_tws.vpcf", PATTACH_ABSORIGIN, target)
                ParticleManager:ReleaseParticleIndex(lock_pfx)


                self:GetCaster():EmitSound("Hero_FacelessVoid.TimeLockImpact")

                local damage_table = {}
                damage_table.owner = self:GetCaster()
                damage_table.victim = target
                damage_table.damage_type = self:GetAbility():GetAbilityDamageType()
                damage_table.ability = self:GetAbility()
                damage_table.damage = self.bonus_damage

                ApplyDamage(damage_table)
            end
        end
    end
end