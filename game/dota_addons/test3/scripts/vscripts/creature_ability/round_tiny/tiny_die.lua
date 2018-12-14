require('libraries/notifications')
require('quest_system')
function announce_tiny_die(key)
    local caster = key.caster
    if caster.die_in_peace~=true then
       if  GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag==false  then
          Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="#round8_acheivement_fail_note", duration=4, style = {color = "Chartreuse"}})
          QuestSystem:RefreshAchQuest("Achievement",1,1)
       end
     GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=true
    end
end
