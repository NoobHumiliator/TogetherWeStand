require( "util" )

function TakeDamage(event)
    local damage = event.Damage
   	local caster = event.caster
	local ability = event.ability
    local attacker = event.attacker
    
    --伤害来源必须是敌方单位
    if caster:GetTeamNumber()~=attacker:GetTeamNumber() then
        local allies = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
        for _,ally in pairs(allies) do  -- 不再伤害本体 
              if ally:HasAbility("share_damage_passive") and ally~=caster  then             
                local damage_table = {}
                damage_table.attacker = caster
                damage_table.victim = ally
                damage_table.damage_type = DAMAGE_TYPE_PURE
                damage_table.ability = caster:FindAbilityByName("share_damage_passive")
                damage_table.damage = damage
                damage_table.damage_flags = DOTA_DAMAGE_FLAG_NONE
                ApplyDamage(damage_table)
              end
        end 
    end

end