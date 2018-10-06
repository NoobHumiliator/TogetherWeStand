LinkLuaModifier( "modifier_environment_blind_lua","environment_controller/modifier_environment_blind_lua", LUA_MODIFIER_MOTION_NONE )



require( "global_setting" )
require( "util" )


if EnvironmentController == nil then
  EnvironmentController = class({})
end

function EnvironmentController:Init()
	self.blindEnd=false
	self.ballInterval=30.0
	self.tombInterval=15.0
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



function EnvironmentController:SpawnTombStone()

    Timers:CreateTimer({
		endTime = 5,
		callback = function()
	 
        local unitName

        if RandomInt(0,3)==0 then 
           unitName="npc_dota_creature_red_tombstone"
        else
           unitName="npc_dota_creature_gold_tombstone"
        end


        for i=1,5 do

        	local hero=RandomEnemyHeroIgnoreImmnue()  --找一个随机英雄 对其周围放置方尖塔
        	if hero then
        		local x = RandomInt(-1700,1700)+hero:GetAbsOrigin().x
        	    local y = RandomInt(-1700,1700)+hero:GetAbsOrigin().y
        	    local position= GetGroundPosition(Vector(x,y,0),nil)
        	    CreateUnitByName(unitName, position, true, nil, nil, DOTA_TEAM_BADGUYS)
        	end
        end
        
		if CHoldoutGameMode._currentRound==nil or  CHoldoutGameMode._currentRound._alias ~="tombstone"  then
		       return nil
		   else
               if CHoldoutGameMode._currentRound._environmentcontroller.tombInterval>3.5 then --最短3.5秒一次
		          CHoldoutGameMode._currentRound._environmentcontroller.tombInterval=CHoldoutGameMode._currentRound._environmentcontroller.tombInterval-0.2  	 
		       end	 		       	
		       return CHoldoutGameMode._currentRound._environmentcontroller.tombInterval 
		   end
		end
		})
end


function EnvironmentController:ApplyBeaconModifier()  --随机选取一个无面者加暗影信标

    Timers:CreateTimer({
		endTime = 25,
		callback = function()
        
        --print("wfffds")
        local units= FindUnitsInRadius(DOTA_TEAM_BADGUYS,Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY,DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false )
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



function RandomEnemyHeroIgnoreImmnue()
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    if #enemies > 0 then
        local index = RandomInt( 1, #enemies )
        return enemies[index]
    else
        return nil
    end
end




function EnvironmentController:AffixesSpawnLaser()

    Timers:CreateTimer({
		endTime = 3,
		callback = function()
	        local hero = RandomHeroIgnoreImmnueAndInvulnerable()

	        if hero then
	            local randomX=RandomInt(-500,500)
	            local randomY=RandomInt(-500,500)
	            local turret = CreateUnitByName("npc_dota_creature_affixes_laser_turret", GetGroundPosition(Vector(hero:GetOrigin().x+randomX,hero:GetOrigin().y+randomY,0),nil), true, nil, nil, DOTA_TEAM_BADGUYS)
	            if CHoldoutGameMode._currentRound==nil or CHoldoutGameMode._currentRound.vAffixes.laser~=true  then
			       return nil
			    else
			       return 10
			    end
	        end
        end
	})
end
