
modifier_ward_earthshaker_aftershock = class({})

--------------------------------------------------------------------------------

function modifier_ward_earthshaker_aftershock:OnCreated( kv )
	self.afterShockAbility = self:GetAbility():GetCaster():FindAbilityByName("earthshaker_aftershock_datadriven")
end

--------------------------------------------------------------------------------
function modifier_ward_earthshaker_aftershock:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_EVENT_ON_SPENT_MANA
	}
	return funcs
end
--------------------------------------------------------------------------------
function modifier_ward_earthshaker_aftershock:OnSpentMana( params )
	if IsServer() then
		if params.unit ~= self:GetParent() then
			return 0
		end

		if params.cost == nil or params.cost == 0 then
			return 0
		end

        if self:GetAbility()~=nil and self:GetAbility():GetCaster()~=nil and self:GetAbility():GetCaster():FindAbilityByName("earthshaker_aftershock_datadriven") then
		    local ability = self:GetAbility():GetCaster():FindAbilityByName("earthshaker_aftershock_datadriven")
		    local caster = self:GetParent()
			local ability_level = ability:GetLevel() - 1
			local cast_ability = params.ability
			local aftershock_particle = "particles/units/heroes/hero_centaur/centaur_warstomp.vpcf"

		    local ability_exempt_table = {}
		    ability_exempt_table["shredder_chakram"]=true
		    ability_exempt_table["shredder_chakram_2"]=true

		    local chance_pass=true  --某些技能概率不通过

		    if RandomInt(0,100)<25 and ability_exempt_table[cast_ability:GetAbilityName()] then  --25% 概率不通过
		       chance_pass=false 
		    end

			-- Parameters
			local damage = ability:GetLevelSpecialValueFor("damage", ability_level)
			local radius = ability:GetLevelSpecialValueFor("radius", ability_level)
			local stun_duration = ability:GetLevelSpecialValueFor("stun_duration", ability_level)
		    if cast_ability and cast_ability:GetManaCost( cast_ability:GetLevel() - 1 ) > 0 and cast_ability:GetCooldown( cast_ability:GetLevel() - 1 ) > 0.05  and chance_pass then
			      local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetOrigin(), nil, radius, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, FIND_ANY_ORDER, false)
			      ability:ApplyDataDrivenModifier(caster, caster, "modifier_shock_particle", {})
			      for _,enemy in pairs(enemies) do		
				  enemy:AddNewModifier(caster, self:GetAbility(), "modifier_stunned", {duration = stun_duration})
				  ApplyDamage({attacker = caster, victim = enemy, ability = self:GetAbility(), damage = damage, damage_type = ability:GetAbilityDamageType()})
			      end      
			end
	    end



	end
end

