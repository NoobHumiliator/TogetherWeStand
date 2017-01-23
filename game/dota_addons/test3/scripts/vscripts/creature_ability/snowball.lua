require( "libraries/physics")
require( "util")

function SnowballStart(keys)

    local ability=keys.ability 
    local caster=keys.caster  --只有土猫能能放这个技能caster 一般是土猫
    
    local tusks= {}
    local allies = FindUnitsInRadius( caster:GetTeam(), caster:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
     
    for _,ally in pairs(allies) do
        if ally:HasAbility("tws_tusk_snowball") then
           table.insert(tusks, ally) --将有这个技能的单位加入此表
        end
    end

    print("tusks size"..#tusks)

    for _,tusk in pairs(tusks) do
    	tusk:FindAbilityByName(ability:GetAbilityName()):StartCooldown(ability:GetCooldown(ability:GetLevel()-1))  --雪球技能进入CD
    	ability:ApplyDataDrivenModifier(tusk,tusk,"modifier_dummy_snowball",{}) --全员进入马甲状态
    	tusk:AddNoDraw() --隐藏施法者
    	local snowball = CreateUnitByName("tusk_snowball",tusk:GetAbsOrigin(),true, nil, nil, DOTA_TEAM_BADGUYS)
    	snowball.snowballOwner=tusk --记录雪球的召唤者

        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_rollingboulder.vpcf", PATTACH_ABSORIGIN_FOLLOW, snowball)
        snowball:FindAbilityByName("snowball_passive"):ApplyDataDrivenModifier(snowball,snowball,"modifier_snowball_invulnerable",{}) --雪球进入马甲状态
        Physics:Unit(snowball)
        snowball:Hibernate(false)
	    snowball:SetPhysicsFriction(0)
        local wp = Entities:FindByName( nil, "waypoint_middle1")
        snowball.targetPosition= RandomLocation(1200)  --以中心为圆心1500半径的随机一点
        snowball:SetAutoUnstuck(false)
		snowball:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		snowball:FollowNavMesh(false)
      
        snowball:SetPhysicsVelocity(  (snowball.targetPosition-snowball:GetAbsOrigin())/2)
        snowball.stopTime=0   --中途几次改变方向

        snowball:OnPhysicsFrame(
			function(unit)
                if snowball:GetPhysicsVelocity().x~=0 then               
	                local angle=math.deg(math.atan(snowball:GetPhysicsVelocity().y/snowball:GetPhysicsVelocity().x))
	                if snowball:GetPhysicsVelocity().x<0 then
	                   angle=angle+180
	                end
					snowball:SetAngles(0,angle, 0)
			    end
			    
				-- 保持地面高度
				snowball:SetAbsOrigin(GetGroundPosition(snowball:GetAbsOrigin(), snowball) + Vector(0, 0, 90))
	            
	            if (snowball.targetPosition-snowball:GetAbsOrigin()):Length()<100 then        
	                if snowball.stopTime>=6 then  --6次后停止
	                	snowball:RemoveModifierByName("modifier_snowball_invulnerable")
	                	snowball:SetPhysicsVelocity(Vector(0,0,0))
	                	snowball:SetAbsOrigin(GetGroundPosition(snowball:GetAbsOrigin(), snowball) + Vector(0, 0, 90))	                	
	                	snowball:OnPhysicsFrame(nil)	                
	                else
	                	snowball:SetPhysicsVelocity(Vector(0,0,0))   --到达某个点 停止0.7秒
	                	snowball.targetPosition=RandomLocation(1200)
	                    Timers:CreateTimer(
						       0.3, function()
							       snowball.stopTime=snowball.stopTime+1
	                               snowball:SetPhysicsVelocity( (snowball.targetPosition-snowball:GetAbsOrigin())/2)
	                           end)
	                end
	            end
	           
			 end
		)

    end

    Timers:CreateTimer({
			endTime = 0.5,
			callback = function()
            local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )  --全地图所有英雄	
			for _,enemy in pairs(allEnemies) do
              if enemy.snowballDotDamage==nil then
              	 enemy.snowballDotDamage=0
              else
              	 enemy.snowballDotDamage=enemy.snowballDotDamage+5 --每次dot增加5点伤害
              end                  
              local damageTable = 
                {
	                victim=enemy,
	                attacker=caster,
	                damage_type=DAMAGE_TYPE_PURE,
	                damage=enemy.snowballDotDamage
                }
              PrintTable(damageTable)
              ApplyDamage(damageTable)
              if enemy.snowballDamageParticleIndex~=nil then--覆盖之前的例子特效
              	 ParticleManager:DestroyParticle(enemy.snowballDamageParticleIndex,true)
              	 ParticleManager:ReleaseParticleIndex(enemy.snowballDamageParticleIndex)
              end
              local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/earthspirit_petrify_debuff_stoned.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
              enemy.snowballDamageParticleIndex=particle
			end
			if snowball==nil or snowball:IsNull() or snowball:IsAlive() then
				return nil
			else
				return 0.5
			end
		end
		})

end

function SnowballDied(event)

   local caster = event.caster  --caster是雪球
   local snowballs= Entities:FindAllByName("tusk_snowball")
   for _,snowball in pairs(snowballs) do
   	  if not snowball:IsNull() then
         --显示雪球施法者,将其移动到雪球死亡的位置
	    snowball.snowballOwner:RemoveNoDraw()
	    snowball.snowballOwner:RemoveModifierByName("modifier_dummy_snowball")
	    snowball.snowballOwner:SetOrigin(caster:GetOrigin())
        if  snowball:IsAlive() then      
		    snowball:RemoveAbility("snowball_passive")  --杀死雪球
		    snowball:ForceKill(true)
   	    end
      end
   end
   if caster.snowballOwner:GetUnitName()=="npc_dota_tusk_boss" then --如果打错了雪球
   	  local allies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
   	  for _,ally in pairs(allies) do --治疗全部友军
		local particle = ParticleManager:CreateParticle("particles/items_fx/aegis_respawn_timer.vpcf", PATTACH_ABSORIGIN_FOLLOW, ally)
		ally:Heal(999999, ally)
		ParticleManager:ReleaseParticleIndex(particle)
	  end 
   else   --如果打对了雪球 所有敌人造成15%伤害
      local damageTable = {victim=caster.snowballOwner,
                           attacker=caster.snowballOwner,
                           damage_type=DAMAGE_TYPE_PURE,
                           damage=caster.snowballOwner:GetMaxHealth()*0.15} 
      ApplyDamage(damageTable)
   end
    
   local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )  --全地图所有英雄	
   for _,enemy in pairs(allEnemies) do
      enemy.snowballDotDamage=0  --Dot叠加器清零
      if enemy.snowballDamageParticleIndex~=nil  then--清楚粒子特效
      	 ParticleManager:DestroyParticle(enemy.snowballDamageParticleIndex,true)
      	 ParticleManager:ReleaseParticleIndex(enemy.snowballDamageParticleIndex)
      	 enemy.snowballDamageParticleIndex=nil
      end
   end
   
end



function RandomLocation(waypoint_radius)
     local  wp = Entities:FindByName( nil, "waypoint_middle1")
     local vector=Vector(RandomFloat(-1,1),RandomFloat(-1,1),0):Normalized()*waypoint_radius
	 local  result=GetGroundPosition(wp:GetAbsOrigin()+vector,nil)
	 return result
end


function Vector2D(v)

	return Vector(v.x, v.y, 0)

end


function Vector2Str(vector)

    return  "("..vector.x..","..vector.y..","..vector.z..")"

end
