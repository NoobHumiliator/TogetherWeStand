require( "libraries/physics")

function SnowballStart(keys)

    local ability=keys.ability

    local tusks= Entities:FindAllByName("tusk_boss")
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
        snowball:SetPhysicsVelocity((snowball.targetPosition-snowball:GetAbsOrigin()))
        snowball.stopTime=0   --中途几次改变方向
        snowball:OnPhysicsFrame(
			function(unit)
				-- 计算旋转角度
				local vAngles = Vector2D(snowball:GetPhysicsVelocity()) / (2 * 3.1415926 * 80)  --角速度
				vAngles = QAngle(vAngles.x, 0, -1 * vAngles.y)
			
				-- 旋转
				local angles = RotateOrientation(vAngles, snowball:GetAngles())
				snowball:SetAngles(angles.x, angles.y, angles.z)

				-- 保持地面高度
				snowball:SetAbsOrigin(GetGroundPosition(snowball:GetAbsOrigin(), snowball) + Vector(0, 0, 80))
	             
	            if (targetPosition-snowball:GetAbsOrigin()):Length()<50 then  
	                snowball.stopTime=snowball.stopTime+1
	                if snowball.stopTime>=6 then  --6次后停止
	                	snowball:SetPhysicsVelocity(Vector(0,0,0))
	                	snowball:OnPhysicsFrame(nil)
	                end
	                snowball.targetPosition=RandomLocation(1500)
	                snowball:SetPhysicsVelocity((snowball.targetPosition-snowball:GetAbsOrigin()))
	            end
	           
			 end
		)

    end

end

function RandomLocation(waypoint_radius)
     local  wp = Entities:FindByName( nil, "waypoint_middle1")
	 local  result=GetGroundPosition:(Vector(RandomFloat(-1,1),RandomFloat(-1,1),0):Normalized()*waypoint_radius+wp:GetAbsOrigin())
	 return result
end