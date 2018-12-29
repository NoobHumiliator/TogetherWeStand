modifier_mage_shield_active = class({})


function modifier_mage_shield_active:GetTexture()
	return "item_mage_shield_2"
end

--------------------------------------------------------------------------------
function modifier_mage_shield_active:OnCreated()
    if IsServer() then
		self.damage_per_mana=self:GetAbility():GetSpecialValueFor( "damage_per_mana" )
		local caster = self:GetParent()
		self.particle = ParticleManager:CreateParticle("particles/items_fx/immunity_sphere_buff.vpcf", PATTACH_CENTER_FOLLOW, self:GetParent()) 
	end
end
--------------------------------------------------------------------------------
function modifier_mage_shield_active:OnDestroy()
    if IsServer() then
		ParticleManager:DestroyParticle(self.particle,true)
	    ParticleManager:ReleaseParticleIndex(self.particle)
	end
end
--------------------------------------------------------------------------------
function modifier_mage_shield_active:OnTakeDamage (event)

    PrintTable(event,nil,nil)
	if event.unit == self:GetParent() then
        
		local caster = self:GetParent()
		local post_damage = event.damage
		local original_damage = event.original_damage
		local ability = self:GetAbility()

        --来自队友的伤害不能被抵抗
        if post_damage>=caster:GetHealth() then --如果造成过量伤害
           local overDamage=post_damage-caster:GetHealth()
           caster:ReduceMana(overDamage/self.damage_per_mana)
           if caster:GetMana()<5 then
              self:Destroy()
           end
        end
	end
end

--------------------------------------------------------------------------------

function modifier_mage_shield_active:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}
	return funcs
end

--------------------------------------------------------------------------------

function modifier_mage_shield_active:GetMinHealth(params)
	return 1
end 
--------------------------------------------------------------------------------
