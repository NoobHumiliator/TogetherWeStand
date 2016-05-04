require('libraries/notifications')
elf_index={}   --储存全部特效的的Index
function cut_elf(variable)
    local caster = variable.caster
    if #elf_index~=0 then  --如果表内还有内容 就删精灵
    ParticleManager:DestroyParticle(elf_index[#elf_index],true)
    table.remove(elf_index, #elf_index)
    end
    if #elf_index~=0 then  --重复
    ParticleManager:DestroyParticle(elf_index[#elf_index],true)
    table.remove(elf_index, #elf_index)
    end
   if #elf_index~=0 then  --重复
    ParticleManager:DestroyParticle(elf_index[#elf_index],true)
    table.remove(elf_index, #elf_index)
    end
   if #elf_index~=0 then  --重复
    ParticleManager:DestroyParticle(elf_index[#elf_index],true)
    table.remove(elf_index, #elf_index)
   end
   local argets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
      for i,nit in pairs(argets) do
           if nit:GetUnitName()==("npc_dota_boss_enchantress") then
           enchantress=nit
           end
      end
        
    if  enchantress then
        if enchantress:GetContext("use_cut_elf_number")==nil then
           enchantress:SetContextNum("use_cut_elf_number", 0, 0) 
        end
        if enchantress:GetContext("use_cut_elf_number")>=1 then
           enchantress:SetContextNum("use_cut_elf_number", enchantress:GetContext("use_cut_elf_number")-1, 0)  --已经减过一波小精灵了，计数器减一 
        end
    end
    local current_heal_level=caster:FindAbilityByName("boss_enchantress_heal"):GetLevel()
    if current_heal_level>=2 then
      caster:FindAbilityByName("boss_enchantress_heal"):SetLevel(current_heal_level-1)   --降级治疗技能
    end
    local current_untouch_level=caster:FindAbilityByName("boss_untouchable"):GetLevel()
    if current_untouch_level>=2 then
      caster:FindAbilityByName("boss_untouchable"):SetLevel(current_untouch_level-1)  --降级不可侵犯
    end
    local current_wrath_level=caster:FindAbilityByName("boss_nature_wrath"):GetLevel() 
    if current_wrath_level>=2 then
      caster:FindAbilityByName("boss_nature_wrath"):SetLevel(current_wrath_level-1)    --降级自然之怒 其实是变强了
      print("now upgrade wrath level to".. caster:FindAbilityByName("boss_nature_wrath"):GetLevel())  
    end
end

function boss_spawn_elf(variable)
    local caster = variable.caster
    for i=1,60 do	   --生成60个精灵 然后存进表里
       local particle= ParticleManager:CreateParticle(variable.EffectName,PATTACH_ABSORIGIN_FOLLOW,caster)
       ParticleManager:SetParticleControl(particle, 0, caster:GetAbsOrigin()+RandomVector(250)) 
       table.insert(elf_index,particle)
    end
    caster:FindAbilityByName("boss_untouchable"):SetLevel(15)   --初始化技能等级
    caster:FindAbilityByName("boss_enchantress_heal"):SetLevel(15)
    caster:FindAbilityByName("boss_nature_wrath"):SetLevel(15)
end

function announce_my_die(variable)
    local caster = variable.caster
    local argets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
      for i,nit in pairs(argets) do
           if nit:GetUnitName()==("npc_dota_boss_enchantress") then
           enchantress=nit
           end
      end
    if  enchantress then
        if enchantress:GetContext("use_cut_elf_number")==nil then
           enchantress:SetContextNum("use_cut_elf_number", 0, 0)   --初始化 
        end
        if enchantress:GetContext("use_cut_elf_number")~=nil then
           enchantress:SetContextNum("use_cut_elf_number", enchantress:GetContext("use_cut_elf_number")+1, 0)  --我死了，计数器加一 
        end
    end
    GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.treeElderDieNumber=GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.treeElderDieNumber+1
    if GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.treeElderDieNumber==10 then
      GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=true
      Notifications:BottomToTeam(DOTA_TEAM_GOODGUYS, {text="#round10_acheivement_fail_note", duration=4, style = {color = "Chartreuse"}})
    end
    Notifications:TopToAll({hero="npc_dota_hero_treant" , imagestyle="portrait"})
    Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#elder_die_simple", duration=1.5, style = {color = "Azure"},continue=true})
end


