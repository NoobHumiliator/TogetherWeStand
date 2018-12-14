function Spawn( entityKeyValues )
	if not IsServer() then
		return
	end

	if thisEntity == nil then
		return
	end

    thisEntity.allies={}

	venomHealAbility = thisEntity:FindAbilityByName( "creature_venom_channel_heal" )
	novaAbility = thisEntity:FindAbilityByName( "creature_venom_poison_nova" )
	thisEntity:SetContextThink( "VenomTriangleThink", VenomTriangleThink, 0.25 )
	thisEntity:SetContextThink( "VenomIncreaseDamage", VenomIncreaseDamage, 3 )

end


function VenomIncreaseDamage()

	if ( not thisEntity:IsAlive() ) then
		return -1
	end
	
	if GameRules:IsGamePaused() == true then
		return 0.25
	end
    
    --增加伤害
    if thisEntity.damageMultiple then
        thisEntity.damageMultiple=thisEntity.damageMultiple*1.1
    end
	
	return 5

end


--------------------------------------------------------------------------------------------------------

function VenomTriangleThink()
	if ( not thisEntity:IsAlive() ) then
		return -1
	end
	
	if GameRules:IsGamePaused() == true then
		return 0.25
	end
     
    local killFlag=true

    --给几个毒蛇附上初始值
	if  (#thisEntity.allies)==0 then 
        local allies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
	    for i = 1, #allies do
			local ally = allies[i]
			if ally ~= nil and ally:IsAlive() and ally:HasAbility("creature_venom_channel_heal") then
	             table.insert (thisEntity.allies,ally)
	             if thisEntity:GetUnitName()=="npc_dota_creature_venom_1" and ally:GetUnitName()=="npc_dota_creature_venom_2" or thisEntity:GetUnitName()=="npc_dota_creature_venom_2" and ally:GetUnitName()=="npc_dota_creature_venom_3" or thisEntity:GetUnitName()=="npc_dota_creature_venom_3" and ally:GetUnitName()=="npc_dota_creature_venom_1" then
	              local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
			      thisEntity.linkParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, thisEntity)
			      ParticleManager:SetParticleControlEnt(thisEntity.linkParticle, 1, ally, PATTACH_POINT_FOLLOW, "attach_hitloc", ally:GetAbsOrigin(), true)
			     end
			end
		end
	end

    for i = 1, #thisEntity.allies do
		local ally = thisEntity.allies[i]
		if ally ~= nil and ally:IsAlive() then
			--如果有人有技能 却没在读条，取消自杀动作
			local allyHealAbility = ally:FindAbilityByName("creature_venom_channel_heal")
			if not allyHealAbility:IsChanneling() then
				killFlag=false
			end
		end
	end


    if killFlag then
    	 thisEntity:ForceKill(false)
    	 return -1 
    end

    if venomHealAbility:IsChanneling() then  
       return 0.25
    end   

    if thisEntity:GetHealth()<thisEntity:GetMaxHealth()*0.05 then
       	ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
			AbilityIndex = venomHealAbility:entindex()
		})
    end

    local enemies = FindUnitsInRadius( thisEntity:GetTeamNumber(), thisEntity:GetOrigin(), nil, 800, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE, FIND_CLOSEST, false )
    if #enemies>0  and novaAbility:IsFullyCastable() then
       CastPoisonNova()
    end

	return AttackNearestEnemy()
	
end
-----------------------------------------------------------------------------------------------------

function AttackNearestEnemy()  --攻击最近的目标

	local target
	local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false )
	if #allEnemies > 0 then
		local minDistance = 10000000
		for _,enemy in pairs(allEnemies) do
			local distance = ( thisEntity:GetOrigin() - enemy:GetOrigin() ):Length()
			if distance < minDistance then
			  minDistance=distance
              target=enemy
			end
		end
	end

    if target~=nil and not thisEntity:IsAttacking() then  --避免打断攻击动作

		ExecuteOrderFromTable({
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET
		})

    end

	local fFuzz = RandomFloat( -0.1, 0.1 ) -- Adds some timing separation to these magi
	return 0.5 + fFuzz
end
--------------------------------------------------------------------------------
function CastPoisonNova()
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = novaAbility:entindex(),
		Queue = false,
	})
	return 0.5
end
--------------------------------------------------------------------------------

--读条加血
function  RestoreHeal(key)
	local caster = key.caster
    caster:Heal(caster:GetMaxHealth(), caster)
    caster:RemoveGesture(ACT_DOTA_FLAIL)
end
--------------------------------------------------------------------------------

--动作
function  StartGesture(key)
	local caster = key.caster

    Timers:CreateTimer({
        endTime = 0.3, 
          callback = function()
          caster:StartGesture( ACT_DOTA_FLAIL )
          if caster:IsAlive() and caster:FindAbilityByName("creature_venom_channel_heal"):IsChanneling() then
             return 0.7
          else
          	 caster:RemoveGesture(ACT_DOTA_FLAIL)
          	 return nil
          end
      end})
end