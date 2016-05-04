--[[
Broodmother Egg Hatching Logic
]]

function Spawn( entityKeyValues )

    local argets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
        for i,nit in pairs(argets) do
                if nit:GetUnitName()==("npc_dota_creature_broodking") then
                hbroodmother=nit
                end
        end
        
    if  hbroodmother then
    	--print("mother found")
    	if hbroodmother:GetContext("mothernumber")==nil then
        hbroodmother:SetContextNum("mothernumber", 0, 0) 
        hbroodmother:SetContextNum("warriornumber", 0, 0) 
        --print("mothernumber first")
        end
    end
	ABILITY_hatch_broodmother = thisEntity:FindAbilityByName( "creature_hatch_broodmother")
	ABILITY_hatch_warrior = thisEntity:FindAbilityByName( "creature_hatch_warrior")
	TIME_TO_HATCH = GameRules:GetGameTime() + ABILITY_hatch_broodmother:GetCooldown( 0 )
	thisEntity:SetContextThink( "WaitToHatch", WaitToHatch, 0.25 )
end


function WaitToHatch()
	if not thisEntity:IsAlive() then
		local nFXIndex = ParticleManager:CreateParticle( "veil_of_discord", PATTACH_ABSORIGIN, thisEntity )
		ParticleManager:SetParticleControl( nFXIndex, 0, thisEntity:GetOrigin() )
		ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
		ParticleManager:ReleaseParticleIndex( nFXIndex )
		return
	end

	local now = GameRules:GetGameTime()
	if now < TIME_TO_HATCH then
		return RandomFloat( 0.1, 0.3 )
	end
	local mothernumber=0
	local warriornumber=0
	local argets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
        for i,nit in pairs(argets) do
                if nit:GetUnitName()==("npc_dota_creature_broodking") then
                hbroodmother=nit
                end
        end
	       if hbroodmother then
	              mothernumber=hbroodmother:GetContext("mothernumber")
           end     
    print(mothernumber)
    if RandomInt(1, 65)>mothernumber-15
    then 
	ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = ABILITY_hatch_broodmother:entindex()
	})
	       if hbroodmother then
	            hbroodmother:SetContextNum("mothernumber", hbroodmother:GetContext("mothernumber") + 1, 0) 
           end
    else
    ExecuteOrderFromTable({
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = ABILITY_hatch_warrior:entindex()
	})
	   if hbroodmother then
	      hbroodmother:SetContextNum("warriornumber", hbroodmother:GetContext("warriornumber") + 1, 0)
	      warriornumber=hbroodmother:GetContext("warriornumber")    --把蜘蛛勇士的数量赋值给这个局部变量
       end
       print("warriornumber"..warriornumber)
	   if warriornumber==15 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
       if warriornumber==20 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
       if warriornumber==25 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
       if warriornumber==29 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
       if warriornumber==33 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
       if warriornumber==36 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
       if warriornumber==39 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
       if warriornumber==41 then
       local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )   
       end
       if warriornumber==43 then
       local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )   
       end
       if warriornumber==45 then
       local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )   
       end
       if warriornumber==47 then
       local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )   
       end
       if warriornumber >47  and warriornumber <=62 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
       if warriornumber >62 and  warriornumber <=88 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )		  
       end
       if warriornumber >88 then
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	
		   local entUnit = CreateUnitByName( "npc_dota_creature_spider_killer", hbroodmother:GetOrigin()+RandomVector( 300 ), true, nil, nil, DOTA_TEAM_BADGUYS )	  
       end
   end
end
