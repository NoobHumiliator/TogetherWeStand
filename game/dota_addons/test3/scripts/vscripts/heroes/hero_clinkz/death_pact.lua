function DeathPact( event )
	local caster = event.caster
	local target = event.target
	local ability = event.ability
	local duration = ability:GetLevelSpecialValueFor( "duration" , ability:GetLevel() - 1 )

    local difficulty=GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty
    local round_number=GameRules:GetGameModeEntity().CHoldoutGameMode._nRoundNumber
    local adjustment=1
    local round_adjustment= math.pow(0.95,round_number) 
    if difficulty==1 then
    	adjustment=1/0.7
    end
    if difficulty==3 then
    	adjustment=1/1.5
    end
    if difficulty>3 then
    	local healthMultiple=1.5*(1+(difficulty-3)*0.08)
    	adjustment=1/healthMultiple
    end


	-- Health Gain
	local health_gain_pct = ability:GetLevelSpecialValueFor( "health_gain_pct" , ability:GetLevel() - 1 ) * 0.01
	local target_health = target:GetHealth()
	local health_gain = math.floor(target_health*health_gain_pct*adjustment*round_adjustment)

	local health_modifier = "modifier_death_pact_health"
	ability:ApplyDataDrivenModifier(caster, caster, health_modifier, { duration = duration })
	caster:SetModifierStackCount( health_modifier, ability, health_gain )
	caster:Heal( health_gain, caster)
    

	-- Damage Gain
	local damage_gain_pct = ability:GetLevelSpecialValueFor( "damage_gain_pct" , ability:GetLevel() - 1 ) * 0.01
	local damage_gain = math.floor(target_health * damage_gain_pct*adjustment*round_adjustment)

	local damage_modifier = "modifier_death_pact_damage"
	ability:ApplyDataDrivenModifier(caster, caster, damage_modifier, { duration = duration })
	caster:SetModifierStackCount( damage_modifier, ability, damage_gain )

	target:Kill(ability, caster)

	print("Gained "..damage_gain.." damage and  "..health_gain.." health".."round_adjustment"..round_adjustment)
	caster.death_pact_health = health_gain
end

-- Keeps track of the casters health
function DeathPactHealth( event )
	local caster = event.caster
	caster.OldHealth = caster:GetHealth()
end
