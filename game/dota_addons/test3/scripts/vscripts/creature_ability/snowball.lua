require( "libraries/physics")

function SnowballStart(keys)

    local ability=keys.ability
    local caster=keys.caster
    
    local tusks= Entities:FindAllByName(caster:GetUnitName())
    for _,tusk in pairs(tusks) do
    	tusk:FindAbilityByName(ability:GetAbilityName()):StartCooldown(ability:GetCooldown(ability:GetLevel()-1))  --雪球技能进入CD
    	ability:ApplyDataDrivenModifier(tusk,tusk,"modifier_dummy_snowball",{}) --全员进入马甲状态
    	local snowball = CreateUnitByName("tusk_snowball",tusk:GetAbsOrigin(),true, nil, nil, DOTA_TEAM_BADGUYS)
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_earth_spirit/espirit_rollingboulder.vpcf", PATTACH_ABSORIGIN_FOLLOW, snowball)
        ParticleManager:SetParticleControlOrientation(particle, 0, Vector(0,180,0), Vector(0,1,0), Vector(1,0,0))

        snowball:FindAbilityByName("snowball_passive"):ApplyDataDrivenModifier(snowball,snowball,"modifier_snowball_invulnerable",{}) --雪球进入马甲状态
        Physics:Unit(snowball)
        snowball:Hibernate(false)
	    snowball:SetPhysicsFriction(0)
        snowball:SetAngles(RandomInt(1,360), RandomInt(1,360), RandomInt(1,360))
        local wp = Entities:FindByName( nil, "waypoint_middle1")
        snowball.targetPosition= RandomLocation(1200)  --以中心为圆心1500半径的随机一点
        snowball.SetGroundBehavior(PHYSICS_GROUND_LOCK)
        snowball:SetAutoUnstuck(false)
		snowball:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		snowball:FollowNavMesh(false)
      
        snowball:SetPhysicsVelocity(  (snowball.targetPosition-snowball:GetAbsOrigin())/10)
        snowball.stopTime=0   --中途几次改变方向

        snowball:OnPhysicsFrame(
			function(unit)
				-- 计算旋转角度
				local vAngles = Vector2D(snowball:GetPhysicsVelocity()) / (2 * 3.1415926 * 80)*360/30  --每帧转动角度
				vAngles = QAngle(0,vAngles.x,vAngles.y)
				-- 旋转
				local angles = RotateOrientation(snowball:GetAngles(),vAngles)
                if snowball:GetPhysicsVelocity().x~=0 then
	                print("vAngles.y/vAngles.x"..snowball:GetPhysicsVelocity().y.."/"..snowball:GetPhysicsVelocity().x)	                 
	                local angle=math.deg(math.atan(snowball:GetPhysicsVelocity().y/snowball:GetPhysicsVelocity().x))
                    if snowball:GetPhysicsVelocity().x<0 then
                       angle=angle+180
                    end
                    print("SetAngles"..angle)
					snowball:SetAngles(0,angle, 0)
			    end

                ParticleManager:SetParticleControlOrientation(particle, 0, Vector(0,180,0), Vector(0,1,0), Vector(1,0,0))
				-- 保持地面高度
				snowball:SetAbsOrigin(GetGroundPosition(snowball:GetAbsOrigin(), snowball) + Vector(0, 0, 80))
	            
	            --print("time: "..GameRules:GetGameTime() )  
	            if (snowball.targetPosition-snowball:GetAbsOrigin()):Length()<100 then  
	                print("snowball.stopTime"..snowball.stopTime)       
	                if snowball.stopTime>=6 then  --6次后停止
	                	snowball:RemoveModifierByName("modifier_snowball_invulnerable")
	                	snowball:SetPhysicsVelocity(Vector(0,0,0))
	                	snowball:OnPhysicsFrame(nil)	                
	                else
	                	snowball:SetPhysicsVelocity(Vector(0,0,0))   --到达某个点 停止0.7秒
	                	snowball.targetPosition=RandomLocation(1200)
	                    Timers:CreateTimer(
						       0.3, function()
							       snowball.stopTime=snowball.stopTime+1
	                               snowball:SetPhysicsVelocity( (snowball.targetPosition-snowball:GetAbsOrigin())/10)
	                           end)
	                end
	            end
	           
			 end
		)

    end
end

function RandomLocation(waypoint_radius)
     local  wp = Entities:FindByName( nil, "waypoint_middle1")
     local vector=Vector(RandomFloat(-1,1),RandomFloat(-1,1),0):Normalized()*waypoint_radius
     --print("vector:"..vector)
	 local  result=GetGroundPosition(wp:GetAbsOrigin()+vector,nil)
	 return result
end


function Vector2D(v)

	return Vector(v.x, v.y, 0)

end


function Vector2Str(vector)

    return  "("..vector.x..","..vector.y..","..vector.z..")"

end
