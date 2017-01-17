require( "libraries/physics")

function SnowballStart(keys)

    local ability=keys.ability
    local caster=keys.caster
    
    local tusks= Entities:FindAllByName(caster:GetUnitName())
    for _,tusk in pairs(tusks) do
    	tusk:FindAbilityByName(ability:GetAbilityName()):StartCooldown(ability:GetCooldown(ability:GetLevel()-1))  --雪球技能进入CD
    	tusk:AddNewModifier(tusk,ability,"dummy_snowball",{}) --全员进入马甲状态
    	local snowball = CreateUnitByName("tusk_snowball",tusk:GetAbsOrigin(),true, nil, nil, DOTA_TEAM_BADGUYS)
        Physics:Unit(snowball)
        snowball:Hibernate(false)
	    snowball:SetPhysicsFriction(0)
        snowball:SetAngles(RandomInt(1,360), RandomInt(1,360), RandomInt(1,360))
        local wp = Entities:FindByName( nil, "waypoint_middle1")
        snowball.targetPosition= RandomLocation(1500)  --以中心为圆心1500半径的随机一点
        snowball.SetGroundBehavior(PHYSICS_GROUND_LOCK)
        snowball:SetAutoUnstuck(false)
		snowball:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		snowball:FollowNavMesh(false)

        snowball:SetPhysicsVelocity(  (snowball.targetPosition-snowball:GetAbsOrigin())/50  )
        snowball.stopTime=0   --中途几次改变方向
        snowball:OnPhysicsFrame(
			function(unit)
				-- 计算旋转角度
				local vAngles = Vector2D(snowball:GetPhysicsVelocity()) / (2 * 3.1415926 * 80)*12  --角速度
				vAngles = QAngle(vAngles.x, 0, -1 * vAngles.y)
			
				-- 旋转
				local angles = RotateOrientation(vAngles, snowball:GetAngles())
				snowball:SetAngles(angles.x, angles.y, angles.z)

				-- 保持地面高度
				snowball:SetAbsOrigin(GetGroundPosition(snowball:GetAbsOrigin(), snowball) + Vector(0, 0, 80))
	             
	            print("snowball.velocity: "..Vector2Str(snowball:GetPhysicsVelocity()) )   
	            --print("time: "..GameRules:GetGameTime() )  
	            if (snowball.targetPosition-snowball:GetAbsOrigin()):Length()<100 then  
	            	 print("snowball.stopTime"..snowball.stopTime)       
	                if snowball.stopTime>=6 then  --6次后停止
	                	snowball:SetPhysicsVelocity(Vector(0,0,0))
	                	snowball:OnPhysicsFrame(nil)	                
	                else		                      
		                snowball.targetPosition=RandomLocation(1500)
		                print("snowball.targetPosition: "..Vector2Str(snowball.targetPosition).."snowball:GetAbsOrigin(): "..Vector2Str(snowball:GetAbsOrigin()) )    
		                snowball:SetPhysicsVelocity( (snowball.targetPosition-snowball:GetAbsOrigin())/50   )
		                print("velocity"..Vector2Str( snowball.targetPosition-snowball:GetAbsOrigin() ) )
		                snowball.stopTime=snowball.stopTime+1
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
