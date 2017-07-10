function GrantExtraLife()
	GameRules:GetGameModeEntity().CHoldoutGameMode.last_live=GameRules:GetGameModeEntity().CHoldoutGameMode.last_live+2  --2次额外生命
end



function InitVipReward()
	local vipMap=GameRules:GetGameModeEntity().CHoldoutGameMode.vipMap
	local steamIdMap=GameRules:GetGameModeEntity().CHoldoutGameMode.steamIdMap
	local sound_flag=false  --是否播放声音
    for k,v in pairs(vipMap) do
    	local nPlayerID= steamIdMap[k]
    	if PlayerResource:HasSelectedHero( nPlayerID ) then
    		if vipMap[k]>=2 then --如果vip等级大于等于2
				local hero = PlayerResource:GetSelectedHeroEntity( nPlayerID )	
				--print("hero"..hero:GetUnitName())		
		    	local particle_a = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hero)
		        ParticleManager:SetParticleControlEnt(particle_a, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetOrigin(), true)
		        local particle_b = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6_lvl3_rays.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hero)
		        ParticleManager:SetParticleControlEnt(particle_a, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetOrigin(), true)
	            Timers:CreateTimer(4.0, function()
		           ParticleManager:DestroyParticle(particle_a,false)
	               ParticleManager:DestroyParticle(particle_b,false)
	               ParticleManager:ReleaseParticleIndex(particle_a)
	               ParticleManager:ReleaseParticleIndex(particle_b)
		        end)
		        GrantExtraLife()
		        sound_flag=true
            end
	    end
    end
    NotifyVipToClient()
    if sound_flag then  --播放只要有一个vip在，播放vip的声音
    	EmitGlobalSound("SOTA.FlagCaptureGood")
    end

end




function NotifyVipToClient()  --将VIP等级告知前台
    
    local vipMap=GameRules:GetGameModeEntity().CHoldoutGameMode.vipMap
    local steamIdMap=GameRules:GetGameModeEntity().CHoldoutGameMode.steamIdMap

    for k,v in pairs(vipMap) do
        local playerId=steamIdMap[tonumber(k)]
        local keys={playerId=playerId,vipLevel=v}                  
        --PrintTable(keys)
        CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(playerId),"NotifyVip", keys) --将VIP等级告知前台
    end

end


function CHoldoutGameMode:ReceiveVipQureySuccess(keys) --前台VIP轮询结果告知后台
  local nPlayerID = keys.playerId
  local playerName=PlayerResource:GetPlayerName(nPlayerID)
  local heroName=PlayerResource:GetSelectedHeroName(nPlayerID)
  local hero = PlayerResource:GetSelectedHeroEntity(nPlayerID)	 
  Notifications:BottomToAll({hero = heroName, duration = 15, continue = true})
  Notifications:BottomToAll({text = playerName.." ", duration = 15, continue = true})
  Notifications:BottomToAll({text = "#taobao_thank_note", duration = 15, style = {color = "Orange"}, continue = true})     
  GrantExtraLife()  --给与队伍额外生命

  --给予例子特效
  local particle_a = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hero)
  ParticleManager:SetParticleControlEnt(particle_a, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetOrigin(), true)
  local particle_b = ParticleManager:CreateParticle("particles/econ/events/ti6/teleport_start_ti6_lvl3_rays.vpcf", PATTACH_CUSTOMORIGIN_FOLLOW, hero)
  ParticleManager:SetParticleControlEnt(particle_a, 0, hero, PATTACH_POINT_FOLLOW, "attach_hitloc", hero:GetOrigin(), true)
  Timers:CreateTimer(4.0, function()
	   ParticleManager:DestroyParticle(particle_a,false)
	   ParticleManager:DestroyParticle(particle_b,false)
	   ParticleManager:ReleaseParticleIndex(particle_a)
	   ParticleManager:ReleaseParticleIndex(particle_b)
  end)

  local keys={playerId=nPlayerID,vipLevel=keys.level}  --前台传回的等级                
   --PrintTable(keys)
  CustomGameEventManager:Send_ServerToPlayer(PlayerResource:GetPlayer(nPlayerID),"NotifyVip", keys) --将VIP等级告知前台
end
