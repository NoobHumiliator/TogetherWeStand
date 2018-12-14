require("abilities/ability_generic")
require('quest_system')

function tiny_wake( keys )
        local caster = keys.caster
        local c_team = caster:GetTeam()
        local targets = FindUnitsInRadius( c_team, caster:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )  --全地图所有单位                             
          for i,unit in pairs(targets) do
              local damageTable = {victim=unit,    --受到伤害的单位
                        attacker=caster,          --造成伤害的单位
                        damage=100000,
                       damage_type=DAMAGE_TYPE_PURE}
                       ApplyDamage(damageTable)    --造成伤害
         end
         local  wp = Entities:FindByName( nil, "waypoint_middle1" )
         local entUnit = CreateUnitByName( "npc_dota_warlock_boss_2", wp:GetOrigin(), true, nil, nil, DOTA_TEAM_BADGUYS )
         Notifications:TopToAll({ability= "tiny_wake"})
         Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#tiny_wake_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})    
end



function tiny_hurt_1( keys )
        local caster = keys.caster
        caster:SetHealth(3000)
end

function tiny_hurt_2( keys )
        local caster = keys.caster
        caster:SetHealth(5000)
        local torso = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_02/tiny_02_body.vmdl"})
        torso:FollowEntity(caster, true)
        local head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_02/tiny_02_head.vmdl"})
        head:FollowEntity(caster, true)
        local left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_02/tiny_02_left_arm.vmdl"})
        left_arm:FollowEntity(caster, true)
        local rigt_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_02/tiny_02_right_arm.vmdl"})
        rigt_arm:FollowEntity(caster, true)
end

function tiny_hurt_3( keys )
        local caster = keys.caster
        caster:SetHealth(11000)
        local torso = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_03/tiny_03_body.vmdl"})
        torso:FollowEntity(caster, true)
        local head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_03/tiny_03_head.vmdl"})
        head:FollowEntity(caster, true)
        local left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_03/tiny_03_left_arm.vmdl"})
        left_arm:FollowEntity(caster, true)
        local rigt_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_03/tiny_03_right_arm.vmdl"})
        rigt_arm:FollowEntity(caster, true)
end

function tiny_hurt_4( keys )
        local caster = keys.caster
        caster:SetHealth(12000)
        caster:FindAbilityByName("tiny_splitter"):SetLevel(2)
        local torso = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_body.vmdl"})
        torso:FollowEntity(caster, true)
        local head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_head.vmdl"})
        head:FollowEntity(caster, true)
        local left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_left_arm.vmdl"})
        left_arm:FollowEntity(caster, true)
        local rigt_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_right_arm.vmdl"})
        rigt_arm:FollowEntity(caster, true)
end

function tiny_hurt_5( keys )
        local caster = keys.caster
        caster:SetHealth(18000)
        caster:FindAbilityByName("tiny_splitter"):SetLevel(3)
        local torso = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_body.vmdl"})
        torso:FollowEntity(caster, true)
        local head = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_head.vmdl"})
        head:FollowEntity(caster, true)
        local left_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_left_arm.vmdl"})
        left_arm:FollowEntity(caster, true)
        local rigt_arm = SpawnEntityFromTableSynchronous("prop_dynamic", {model = "models/heroes/tiny_04/tiny_04_right_arm.vmdl"})
        rigt_arm:FollowEntity(caster, true)
end


function tiny_eat(keys)
   local targets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0,0,0) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
   if #targets > 0 then
       for i,unit in pairs(targets) do                 
           if unit:GetUnitName()==("npc_dota_tiny_1") or unit:GetUnitName()==("npc_dota_tiny_2") or unit:GetUnitName()==("npc_dota_tiny_3") or unit:GetUnitName()==("npc_dota_tiny_4") or unit:GetUnitName()==("npc_dota_tiny_5") then       
              unit:SetHealth(unit:GetHealth()+unit:GetMaxHealth()*0.03)
           end 
       end
   end     
end

function tiny_collapse(keys)
    local caster = keys.caster
    local collapse_hurt=caster:GetMaxHealth()*0.08
    if (caster:GetHealth()-collapse_hurt)<1 then
        caster:ForceKill(true)
    else
    caster:SetHealth(caster:GetHealth()-collapse_hurt)
    end
end


function remove_wake_ability(keys)
    local argets = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector( 0, 0, 0 ) , nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false)
    local tiny_5=nil
      for i,nit in pairs(argets) do
           if nit:GetUnitName()==("npc_dota_tiny_5") then
           tiny_5=nit
           end
      end
    if tiny_5 and tiny_5:FindAbilityByName("tiny_wake") then
       tiny_5:RemoveAbility("tiny_wake")
    end  
end