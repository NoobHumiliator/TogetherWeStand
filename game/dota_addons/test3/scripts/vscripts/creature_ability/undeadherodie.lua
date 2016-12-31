require('libraries/notifications')
require('quest_system')
function CheckCaveLord( event )
	local caster = event.caster
	local ability = event.ability
    local target=nil
    local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
        if #targets > 0 then
           for i,unit in pairs(targets) do                 
               if unit:GetUnitName()==("npc_dota_boss_cavelord") then     
                   target=unit
               end 
           end
       end
	if target==nil  then
      if GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag==true then
       Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="#round2_acheivement_fail_note", duration=4, style = {color = "Orange"}})
      end
     QuestSystem:RefreshAchQuest("Achievement",0,1) 
     GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=false
	end
  
	if target~=nil then
	  if  not target:IsAlive() then
	   if GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag==true then
         Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="#round2_acheivement_fail_note", duration=4, style = {color = "Orange"}})
     end
     QuestSystem:RefreshAchQuest("Achievement",0,1)
	   GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=false
	  end
	end
end
