--[[ 	Author: Hewdraw
		Date: 17.05.2015	]]

function RestoreMana( keys )
	local caster = keys.caster
	local target = keys.unit
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1
	local cast_ability = keys.event_ability
	local essence_particle = keys.essence_particle
	local essence_sound = keys.essence_sound

   local exempt_table = {}
	exempt_table["shredder_chakram"]=true
    exempt_table["shredder_chakram_2"]=true

	-- Parameters
	local restore_amount = ability:GetLevelSpecialValueFor("restore_amount", ability_level)
	local mana_restore = target:GetMaxMana() * restore_amount / 100

	-- If the ability just cast uses mana, restore mana accordingly
	if cast_ability and cast_ability:GetManaCost( cast_ability:GetLevel() - 1 ) > 0 and cast_ability:GetCooldown( cast_ability:GetLevel() - 1 ) > 1.01  and not exempt_table[cast_ability:GetAbilityName()]  then
		-- Restores mana
		target:GiveMana(mana_restore)
		-- Plays sound and effect
		local essence_fx = ParticleManager:CreateParticle(essence_particle, PATTACH_ABSORIGIN_FOLLOW, target)
		target:EmitSound("essence_sound")
	end

    local checkFlag=true  --高法强降低奥法天球触发率

    if target.sp~=nil then
       if RandomInt(0,100)< target.sp*40 then  --满级法强 只有0.4*0.2概率触发
          checkFlag=false
       end
    end

	if cast_ability and cast_ability:GetAbilityName()=="obsidian_destroyer_arcane_orb"  and checkFlag  then
		-- Restores mana
		target:GiveMana(mana_restore)
		-- Plays sound and effect
		local essence_fx = ParticleManager:CreateParticle(essence_particle, PATTACH_ABSORIGIN_FOLLOW, target)
		target:EmitSound("essence_sound")
	end
end


