LinkLuaModifier( "modifier_environment_blind_lua","environment_controller/modifier_environment_blind_lua", LUA_MODIFIER_MOTION_NONE )

if EnvironmentController == nil then
  EnvironmentController = class({})
end

function EnvironmentController:Init()
	self.blindEnd=false
	self.ballInterval=30.0
	self.spawnPosition = Entities:FindAllByName( "*waypoint*" )
	for i = 1, #self.spawnPosition do
		self.spawnPosition[i] = self.spawnPosition[i]:GetOrigin()
	end
end



function EnvironmentController:ApplyBlindModifier()

    Notifications:TopToAll({ability= "night_stalker_darkness"})
    Notifications:TopToAll({text="#round_night_darkness_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
    Timers:CreateTimer({
			endTime = 1,
			callback = function()
			local enemies= FindUnitsInRadius( DOTA_TEAM_BADGUYS,Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
			for _,enemy in pairs(enemies) do
				 if enemy:GetUnitName()~="npc_light_ball_dummy" and not enemy:HasModifier("modifier_light_ball_dummy_aura_good_effect")  then 
					enemy:AddNewModifier(enemy,nil,"modifier_environment_blind_lua", {duration = 1})
				 end
			end     	 
			if CHoldoutGameMode._currentRound==nil or  CHoldoutGameMode._currentRound._alias ~="darkness" or CHoldoutGameMode._currentRound._environmentcontroller.blindEnd  then
			       return nil
			   else
			   	return 0.5
			   end
			end
			})
end


function EnvironmentController:SpawnLightBall()

    Timers:CreateTimer({
			endTime = 5,
			callback = function()
			local randomInt=RandomInt(1,#self.spawnPosition)
            local light_ball = CreateUnitByName("npc_dota_creature_light_ball", self.spawnPosition[randomInt], true, nil, nil, DOTA_TEAM_BADGUYS)
			CHoldoutGameMode._currentRound._environmentcontroller.ballInterval=CHoldoutGameMode._currentRound._environmentcontroller.ballInterval+2.0  	 
			if CHoldoutGameMode._currentRound==nil or  CHoldoutGameMode._currentRound._alias ~="darkness" or CHoldoutGameMode._currentRound._environmentcontroller.blindEnd  then
			       return nil
			   else
			       return CHoldoutGameMode._currentRound._environmentcontroller.ballInterval 
			   end
			end
			})
end




function EnvironmentController:ApplyBeaconModifier()  --随机选取一个无面者加暗影信标

    Timers:CreateTimer({
		endTime = 25,
		callback = function()
        
        --print("wfffds")
        local units= FindUnitsInRadius(DOTA_TEAM_BADGUYS,Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
		local faceless_monsters={}
		for _,unit in pairs(units) do
			 if unit:GetUnitName()=="npc_dota_faceless_monster" then 
			 	table.insert(faceless_monsters,unit)
			 end
		end
        --print("#faceless_monsters"..#faceless_monsters)
        if #faceless_monsters>1 then
            local i=RandomInt(1,#faceless_monsters)
            local monster=faceless_monsters[i]
            local ability=monster:FindAbilityByName("faceless_shadow_beacon")
            ability:ApplyDataDrivenModifier(monster,monster,"modifier_shadow_beacon", {duration = 5})            
            monster:EmitSound("Hero_Dazzle.Shallow_Grave")
        end
       
        if CHoldoutGameMode._currentRound==nil or  CHoldoutGameMode._currentRound._alias ~="faceless"  then
		       return nil
		   else
		       return 10	       
		   end
		end

     })
end