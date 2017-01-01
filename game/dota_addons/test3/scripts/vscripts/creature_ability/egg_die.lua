require('libraries/notifications')
require('quest_system')
function announce_egg_die(key)
    local caster = key.caster
    if caster.die_in_peace~=true then
      if  GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag==true then

        QuestSystem:RefreshAchQuest("Achievement",0,1) 
        Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="#round7_acheivement_fail_note", duration=4, style = {color = "Orange"}})
      end
      GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=false
     --GameRules:SendCustomMessage("egg_die", 0, 0)
    end
end

function DieInPeace(key)
    local caster = key.caster
    caster.die_in_peace=true
    --GameRules:SendCustomMessage(" die in peace", 0, 0)
end



