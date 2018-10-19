modifier_boss_sand_king_passive = class({})

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:IsHidden()
	return true
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:OnCreated( kv )
	if IsServer() then
		self:GetCaster().bInSandStorm = false
	end
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:CheckState()
	local state =
	{
		[MODIFIER_STATE_HEXED] = false,
		[MODIFIER_STATE_ROOTED] = false,
		[MODIFIER_STATE_SILENCED] = false,
		[MODIFIER_STATE_STUNNED] = false,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = true,
	}

	if IsServer() then
		state[MODIFIER_STATE_CANNOT_MISS] = self.bCannotMiss
		state[MODIFIER_STATE_INVISIBLE] = false
		state[MODIFIER_STATE_UNSELECTABLE] = self:GetCaster().bInSandStorm
	end
	return state
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:DeclareFunctions()
	local funcs =
	{
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_START,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
		MODIFIER_PROPERTY_EVASION_CONSTANT,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}
	return funcs
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:GetModifierFixedAttackRate( params )
	return 1
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:GetModifierAttackRangeBonus( params )
	if IsServer() then
		if self.bInAttack == true then
			return 200
		else
			return 0
		end
	end
	return 0
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:GetModifierMoveSpeed_Absolute( params )
	return 450
end


-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:OnAttackStart( params )
	if IsServer() then
		if self:GetParent() == params.attacker then
			self.bInAttack = true
			if RollPercentage( self:GetAbility():GetSpecialValueFor( "accuracy_pct" ) ) then
				self.bCannotMiss = true
			else
				self.bCannotMiss = false
			end
		end
	end
	return 0
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:OnAttackLanded( params )
	if IsServer() then
		if self:GetParent() == params.attacker then
			self.bInAttack = false

			local Target = params.target
			if Target ~= nil then
				local caustic_duration = self:GetAbility():GetSpecialValueFor( "caustic_duration" )
				local hCausticBuff = Target:FindModifierByName( "modifier_sand_king_boss_caustic_finale" )
				if hCausticBuff == nil then
					hCausticBuff = Target:AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_sand_king_boss_caustic_finale", { duration = caustic_duration } )
					if hCausticBuff ~= nil then
						hCausticBuff:SetStackCount( 0 )
					end	
				end
				if hCausticBuff ~= nil then
					hCausticBuff:SetStackCount( hCausticBuff:GetStackCount() + 1 )  
					hCausticBuff:SetDuration( caustic_duration, true )
				end		
			end
		end
	end
	return 0 
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:GetModifierEvasion_Constant( params )
	return 33
end

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_passive:OnTakeDamage( params )
	if IsServer() then
		local hAttacker = params.attacker
		local hVictim = params.unit
		if hAttacker ~= nil and hVictim ~= nil and hVictim == self:GetParent() then
			if hVictim:FindModifierByName( "modifier_provide_vision" ) == nil then
				print( "Provide Vision" )
				hVictim:AddNewModifier( hAttacker, self:GetAbility(), "modifier_provide_vision", { duration = -1 } ) 
			end
		end
	end
	return 0
end