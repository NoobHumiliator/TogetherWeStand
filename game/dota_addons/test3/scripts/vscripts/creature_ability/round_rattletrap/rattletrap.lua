require( "ai_core" )

DX = {0, 1, 0, -1}
DY = {1, 0, -1, 0}

DX_DIAG = {1, 1, -1, -1}
DY_DIAG = {1, -1, -1, 1}

power_cogs_sounds={"rattletrap_ratt_ability_cogs_01","rattletrap_ratt_ability_cogs_05","rattletrap_ratt_ability_cogs_03","rattletrap_ratt_ability_cogs_04","rattletrap_ratt_attack_04"}
gears_up_sounds={"rattletrap_ratt_level_01","rattletrap_ratt_level_03","rattletrap_ratt_level_06","rattletrap_ratt_level_11"}




--[[
0 未开始
1 迷宫1进程
2 迷宫1结束 2未开始
3 迷宫2进程 
4 迷宫2结束
]]

function ShuffleList(list)

    local result = list
    local size = #result
    
    for i = 1,size do
        local p = RandomInt(i,size)
        local aux = result[p]
        result[p] = result[i]
        result[i] = aux
    end
    
    return result

end



if TecMazeCreater == nil then
  TecMazeCreater = class({})
  TecMazeCreater.boom_interval=0.16
  TecMazeCreater.boom_damage=240
end

TEC_MAZE_WALL_SIZE = 160

function TecMazeCreater:Init()

  -- Find the environment parameters of the MAZE
  self.destroy_flag=false
  self._corner_bottom_left = Entities:FindByName(nil, "MAZE_corner_bottom_left"):GetAbsOrigin()
  self._corner_top_right = Entities:FindByName(nil, "MAZE_corner_top_right"):GetAbsOrigin()
    self._skip_hole={}
  local size = self._corner_top_right - self._corner_bottom_left
  local w = math.floor(math.abs(size.x) / TEC_MAZE_WALL_SIZE) + 1
  local h = math.floor(math.abs(size.y) / TEC_MAZE_WALL_SIZE) + 1
  
  if w % 2 == 0 then w = w - 1 end
  if h % 2 == 0 then h = h - 1 end

  -- Generate a random MAZE
  local MAZE = {}
  self.bombs={}
  
  -- Initialize a empty grid
  for i = 1,w do
    MAZE[i] = {}
    self.bombs[i] = {}
    for j = 1,h do
      if i==1 or i==w then
      MAZE[i][j] = {block = 1}
        elseif j==1 or j==h then
        MAZE[i][j] = {block = 1}
            else
            MAZE[i][j] = {block = 0}  
      end 
    end
  end
  

  -- Make walls with  recursion
  self._tr={x=w-1,y=h-1}
  self._bl={x=2,y=2}
  self:REC(MAZE,self._tr,self._bl)
  
 
  -- Make the MAZE accessible from the outside
  MAZE[1][6].block = 0
  MAZE[2][6].block = 0
  MAZE[w][math.floor(h/2)].block = 0
  MAZE[w-1][math.floor(h/2)].block = 0
    

    for _,i in pairs(self._skip_hole) do
      MAZE[i.x][i.y].block=0
    end
      


  for i = 1,w do
    for j = 1,h do
      local position = self:GetPosition(i, j)
      local block = MAZE[i][j].block    
      if block==1 then
        local name = "npc_maze_wall"
        local wall = CreateUnitByName(name, position,false, nil, nil, DOTA_TEAM_NEUTRALS)
        wall:SetHullRadius(TEC_MAZE_WALL_SIZE / 2 + 2)
      end
    end
  end 
   self.maze=MAZE
   self.w=w
   self.h=h
   Timers:CreateTimer({
      endTime = 1,
      callback = function()
          local coordinate=TecMazeCreater:FindClearPlaceforBomb(w,h)
        local bomb = CreateUnitByName('bomber_bomb', TecMazeCreater:GetPosition(coordinate.x,coordinate.y), true, nil, nil, DOTA_TEAM_NEUTRALS)
        bomb.x=coordinate.x
        bomb.y=coordinate.y
        TecMazeCreater.bombs[coordinate.x][coordinate.y] = bomb
        if TecMazeCreater.destroy_flag==false then
          return TecMazeCreater.boom_interval
        else
          return nil
        end
      end
    })
   Timers:CreateTimer({
      endTime = 1,
      callback = function()
          local coordinate=TecMazeCreater:FindClearPlaceforBomb(w,h)
        local stasis_trap = CreateUnitByName('stasis_trap', TecMazeCreater:GetPosition(coordinate.x,coordinate.y), true, nil, nil, DOTA_TEAM_BADGUYS)
        if TecMazeCreater.destroy_flag==false then
          return TecMazeCreater.boom_interval
        else
          return nil
        end
      end
    })
end


function TecMazeCreater:GetPosition(x, y)

  return self._corner_bottom_left + (x - 1) * Vector(TEC_MAZE_WALL_SIZE,0,0) +
    (y - 1) * Vector(0,TEC_MAZE_WALL_SIZE,0)

end



function TecMazeCreater:FindClearPlaceforBomb(w,h)
  local MAZE=self.maze
  local maze_coordinate={}
    local x=RandomInt(1,w)
    local y=RandomInt(1,h)
    while MAZE[x][y].block~=0 or self.bombs[x][y]~=nil do
      x=RandomInt(1,w)
      y=RandomInt(1,h)
    end
    maze_coordinate.x=x
    maze_coordinate.y=y
  return maze_coordinate
end


function TecMazeCreater:REC(MAZE, top_right, bottom_left)

    local w=top_right.x-bottom_left.x+1
    local h=top_right.y-bottom_left.y+1
  -- Check if we reached the max level
  if 1<=w and w<=2 and h>2 then   
     local wall=RandomInt(2,h-1)
     local hole=RandomInt(1,w)
     local abs_wall_y=top_right.y-(wall-1)
     local abs_hole_x=bottom_left.x+hole-1
     for i=bottom_left.x,top_right.x do
         if abs_hole_x==i then
               MAZE[i][abs_wall_y].block=0
               else
               MAZE[i][abs_wall_y].block=1
               end
         end
         local top_right_new_1=top_right
         local bottom_left_new_1={x=bottom_left.x,y=abs_wall_y+1}
         self:REC(MAZE,top_right_new_1,bottom_left_new_1)
         local top_right_new_2={x=top_right.x,y=abs_wall_y-1}
         local bottom_left_new_2=bottom_left
         self:REC(MAZE,top_right_new_2,bottom_left_new_2)
  end
    if 1<=h and h<=2 and w>2 then   
     local wall=RandomInt(2,w-1)
     local hole=RandomInt(1,h)
     local abs_wall_x=top_right.x-(wall-1)
     local abs_hole_y=bottom_left.y+hole-1
     for i=bottom_left.y,top_right.y do
         if abs_hole_y==i then
               MAZE[abs_wall_x][i].block=0
               else
               MAZE[abs_wall_x][i].block=1
               end
         end
         local top_right_new_1=top_right
         local bottom_left_new_1={x=abs_wall_x+1,y=bottom_left.y}
         self:REC(MAZE,top_right_new_1,bottom_left_new_1)
         local top_right_new_2={x=abs_wall_x-1,y=top_right.y}
         local bottom_left_new_2=bottom_left
         self:REC(MAZE,top_right_new_2,bottom_left_new_2)
  end
  if h>2 and w>2 then
    local wall_x=RandomInt(2,w-1)
    local wall_y=RandomInt(2,h-1)
    local abs_wall_x=top_right.x-(wall_x-1)
    local abs_wall_y=top_right.y-(wall_y-1)
    local not_to_dig=RandomInt(1,4)
    local hole_1=RandomInt(1,top_right.x-abs_wall_x) --right
    local hole_2=RandomInt(1,top_right.y-abs_wall_y)  --up
    local hole_3=RandomInt(1,abs_wall_x-bottom_left.x) --left
    local hole_4=RandomInt(1,abs_wall_y-bottom_left.y)  --down
    for i=bottom_left.x,top_right.x do
      for j=bottom_left.y,top_right.y do
         if i==abs_wall_x or j==abs_wall_y then
         MAZE[i][j].block=1 
             end
             if i==abs_wall_x+hole_1 and j== abs_wall_y and not_to_dig~=1 then
                MAZE[i][j].block=0
                table.insert(self._skip_hole,{x=i,y=j-1})
        table.insert(self._skip_hole,{x=i,y=j+1})
             end
             if i==abs_wall_x  and j== abs_wall_y+hole_2 and not_to_dig~=2 then
                MAZE[i][j].block=0
                table.insert(self._skip_hole,{x=i-1,y=j})
        table.insert(self._skip_hole,{x=i+1,y=j})
             end
             if i==abs_wall_x-hole_3 and j== abs_wall_y and not_to_dig~=3 then
                MAZE[i][j].block=0
                table.insert(self._skip_hole,{x=i,y=j+1})
        table.insert(self._skip_hole,{x=i,y=j-1})
             end
             if i==abs_wall_x and j == abs_wall_y-hole_4 and not_to_dig~=4 then
                MAZE[i][j].block=0
                table.insert(self._skip_hole,{x=i-1,y=j})
        table.insert(self._skip_hole,{x=i+1,y=j})
             end
            end
        end
        local top_right_new_1=top_right
        local bottom_left_new_1={x=abs_wall_x+1,y=abs_wall_y+1}
        self:REC(MAZE,top_right_new_1,bottom_left_new_1)
        local top_right_new_2={x=abs_wall_x-1,y=top_right.y}
        local bottom_left_new_2={x=bottom_left.x,y=abs_wall_y+1}
        self:REC(MAZE,top_right_new_2,bottom_left_new_2)
        local top_right_new_3={x=abs_wall_x-1,y=abs_wall_y-1}
        local bottom_left_new_3=bottom_left
        self:REC(MAZE,top_right_new_3,bottom_left_new_3)
        local top_right_new_4={x=top_right.x,y=abs_wall_y-1}
        local bottom_left_new_4={x=abs_wall_x+1,y=bottom_left.y}
        self:REC(MAZE,top_right_new_4,bottom_left_new_4)
    end
    if h<=2 and w<=2 then
      return
    end
    if h==0 or w==0 then
      return
    end
end
function BombExplode( keys )
  TecMazeCreater:ExplodeBomb(keys.caster,4)
end

function TecMazeCreater:ExplodeBomb(bomb,power)
  
    local x=bomb.x
    local y=bomb.y
    local MAZE=self.maze
    local w=self.w
    local h=self.h
    StartSoundEventFromPosition ( "Hero_Techies.LandMine.Detonate", bomb:GetOrigin())
  local blastedCells = {}
    for i = 1,w do
    blastedCells[i] = {}  
  end
  for bx=x, math.min(w,x+power) do
    if MAZE[bx][y].block==0 then
      blastedCells[bx][y] = 1     
    else
      break
    end
  end
  
  for bx=x, math.max(1,x-power), -1 do
    if MAZE[bx][y].block==0 then
      blastedCells[bx][y] = 1     
    else
      break
    end
  end
  
  --calculate the reach of the explosion travelling up
  for by=y, math.min(h,y+power) do
    if MAZE[x][by].block==0 then
      blastedCells[x][by] = 1     
    else
      break
    end
  end
  
  --calculate the reach travelling down
  for by=y, math.max(1,y-power), -1 do
    if MAZE[x][by].block==0 then
      blastedCells[x][by] = 1     
    else
      break
    end
  end
  
  --check what we hit
  local hitHeroes = {}
  local hitBombs = {}
  
  for cx=1, w do
    for cy=1,h do
      if blastedCells[cx][cy]==1 then
        local targets = FindUnitsInRadius(DOTA_TEAM_NEUTRALS,self:GetPosition(cx, cy), nil,TEC_MAZE_WALL_SIZE/2+16, DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_HERO+DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, true)
            for i,unit in pairs(targets) do
                if unit:GetUnitName()~="npc_dota_boss_rattletrap" then
                   local damageTable = {victim=unit,
                                     attacker=bomb,
                                     damage=self.boom_damage,
                                     damage_type=DAMAGE_TYPE_PURE}
                   ApplyDamage(damageTable)    --造成伤害
                end
            end
        local particle = ParticleManager:CreateParticle("particles/units/heroes/hero_techies/techies_land_mine_explode.vpcf", PATTACH_ABSORIGIN, bomb)
        local position=self:GetPosition(cx, cy)
        ParticleManager:SetParticleControl(particle, 0, self:GetPosition(cx, cy) )-- set position
        if self.bombs[cx][cy] and not (cx == x and cy==y) then
          hitBombs[#hitBombs+1] = {x=cx, y=cy}
        end
      end
    end
  end

  self.bombs[x][y] = nil
  Timers:CreateTimer(0.5, function()
      if bomb~=nil  and not bomb:IsNull() then
       bomb:RemoveSelf()
      end
  end)
   for _, bombPos in pairs(hitBombs) do
    local bomb = self.bombs[bombPos.x][bombPos.y]
    if bomb then
      self:ExplodeBomb(bomb,4)
    end
  end

  return 
end


function StasisTrapTracker( keys )
  local caster = keys.caster
  local ability = keys.ability

  -- Ability variables
  local activation_radius = 250
  local explode_delay = 1.2
  local vision_radius = 300
  local vision_duration = 1.0
  local modifier_trigger = keys.modifier_trigger

  -- Target variables
  local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
  local target_types = DOTA_UNIT_TARGET_HERO
  local target_flags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES

  -- Find the valid units in the trigger radius
  local units = FindUnitsInRadius(DOTA_TEAM_NEUTRALS, caster:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false) 

  -- If there is a valid unit in range then explode the mine
  if #units > 0 then
    caster:SetModel("models/items/techies/bigshot/fx_bigshot_stasis.vmdl")
      caster:SetOriginalModel("models/items/techies/bigshot/fx_bigshot_stasis.vmdl")
      caster:StartGesture(ACT_DOTA_SPAWN)
    Timers:CreateTimer(explode_delay, function()
      if caster:IsAlive() then
        ability:ApplyDataDrivenModifier(caster, caster, modifier_trigger, {})
        -- Create vision upon exploding
        ability:CreateVisibilityNode(caster:GetAbsOrigin(), vision_radius, vision_duration)
      end
    end)
  end
end



function StasisTrapRemove( keys )
  local target = keys.target
  local ability = keys.ability
  local ability_level = ability:GetLevel() - 1

  -- Ability variables
  local activation_radius = 250
  local unit_name = target:GetUnitName()

  -- Target variables
  local target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
  local target_types = DOTA_UNIT_TARGET_ALL
  local target_flags = DOTA_UNIT_TARGET_FLAG_NONE

  local units = FindUnitsInRadius(target:GetTeamNumber(), target:GetAbsOrigin(), nil, activation_radius, target_team, target_types, target_flags, FIND_CLOSEST, false)

  for _,unit in ipairs(units) do
    if unit:GetUnitName() == unit_name then
      unit:ForceKill(true) 
    end
  end
end



function CheckForMaze( keys )
    local caster = keys.caster
    local ability=keys.ability
    if caster.maze_switch==nil then
       caster.maze_switch=0 
    end
    if caster:GetHealth() < caster:GetMaxHealth()*0.8  and  caster:GetHealth() > caster:GetMaxHealth()*0.5  and  caster.maze_switch==0 then

       Notifications:TopToAll({ability= "rattletrap_power_cogs"})
       Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#cogs_maze_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
       GridNav:DestroyTreesAroundPoint( Vector(0,0,0), 9999, false )
       local randomInt=RandomInt(1,5)
       EmitSoundOn(power_cogs_sounds[randomInt],caster)
       TecMazeCreater:Init()
       local duration =2.0
       local pull_end_time = GameRules:GetGameTime()+2.0
       local units = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

        local target_location=Entities:FindByName(nil, "waypoint_middle1"):GetAbsOrigin()

        for _,unit in ipairs(units) do
         unit:EmitSound("Hero_Rattletrap.Power_Cogs")
         local unit_location = unit:GetAbsOrigin()
         local vector_distance = target_location - unit_location
         local distance = (vector_distance):Length2D()
         local direction = (vector_distance):Normalized()

        -- Check if its a new vacuum cast
        -- Set the new pull speed if it is

         unit.pull_speed = distance * 1/duration * 1/30

        -- Apply the stun and no collision modifier then set the new location
         ability:ApplyDataDrivenModifier(caster, unit, 'modifier_maze_vacuum_datadriven', {duration = 2})

         Timers:CreateTimer({
                  endTime = 0.1,
                  callback =function()
                  local unit_location = unit:GetAbsOrigin()
                  unit:SetAbsOrigin(unit_location + direction * unit.pull_speed)
                  if GameRules:GetGameTime() > pull_end_time then
                   return nil
                  else 
                   return 0.03
                  end
            end})
        end
       caster.maze_switch=1
    end
    if caster:GetHealth() < caster:GetMaxHealth()*0.5  and  caster:GetHealth() > caster:GetMaxHealth()*0.3  and  caster.maze_switch==1 then
       TecMazeCreater.destroy_flag=true
       caster:EmitSound("Hero_Rattletrap.Power_Cog.Destroy")
       local units = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
        for _,unit in ipairs(units) do
         unit:ForceKill(true)
        end
       local traps = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
        for _,trap in ipairs(traps) do
          if trap~=caster then
            trap:ForceKill(true)
          end
        end
        caster.maze_switch=2
    end
   if caster:GetHealth() < caster:GetMaxHealth()*0.3   and  caster.maze_switch==2 then
       Notifications:TopToAll({ability= "rattletrap_power_cogs"})
       Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#cogs_maze_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
       GridNav:DestroyTreesAroundPoint( Vector(0,0,0), 9999, false )
       local randomInt=RandomInt(1,5)
       EmitSoundOn(power_cogs_sounds[randomInt],caster)
       TecMazeCreater:Init()
       local duration =2.0
       local pull_end_time = GameRules:GetGameTime()+2.0
       local units = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)

        local target_location=Entities:FindByName(nil, "waypoint_middle1"):GetAbsOrigin()

        for _,unit in ipairs(units) do
         unit:EmitSound("Hero_Rattletrap.Power_Cogs")
         local unit_location = unit:GetAbsOrigin()
         local vector_distance = target_location - unit_location
         local distance = (vector_distance):Length2D()
         local direction = (vector_distance):Normalized()

        -- Check if its a new vacuum cast
        -- Set the new pull speed if it is

         unit.pull_speed = distance * 1/duration * 1/30

        -- Apply the stun and no collision modifier then set the new location
         ability:ApplyDataDrivenModifier(caster, unit, 'modifier_maze_vacuum_datadriven', {duration = 3})

         Timers:CreateTimer({
                  endTime = 0.1,
                  callback =function()
                  local unit_location = unit:GetAbsOrigin()
                  unit:SetAbsOrigin(unit_location + direction * unit.pull_speed)
                  if GameRules:GetGameTime() > pull_end_time then
                   return nil
                  else 
                   return 0.03
                  end
            end})
        end
       caster.maze_switch=3
    end
end


function CheckMyDied(keys)
    local caster=keys.caster
    TecMazeCreater.destroy_flag=true
    GameRules:SetTreeRegrowTime( 30.0 )
    if GameRules:GetGameTime()-caster.spawn_time>120 then
      GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.achievement_flag=false
    end

    Timers:CreateTimer({
                  endTime = 1,
                  callback =function()

    local units = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
       for _,unit in ipairs(units) do
         unit:ForceKill(true)
        end
    local traps = FindUnitsInRadius(caster:GetTeamNumber(), Vector(0,0,0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_BASIC, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES+DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false)
      for _,trap in ipairs(traps) do
         if trap~=caster then
           trap:ForceKill(true)
         end
      end  
      end})
end



behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
  if thisEntity.spawn_time==nil then
     thisEntity.spawn_time=GameRules:GetGameTime()
     thisEntity.upgrade_time=GameRules:GetGameTime()
  end
  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
  behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorLaunchMissile, BehaviorRun,BehaviorNone } )
end

function AIThink()
  if thisEntity:IsNull() or not thisEntity:IsAlive() then
    return nil -- deactivate this think function
  end


  if GameRules:GetGameTime()-thisEntity.upgrade_time>20 then 
     Notifications:TopToAll({ability="tinker_rearm"})
     Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#gears_upgrade_dbm", duration=1.5, style = {color = "Azure"},continue=true})
     
     local randomInt=RandomInt(1,4)
     EmitSoundOn(gears_up_sounds[randomInt],thisEntity)
     
     local level=thisEntity:FindAbilityByName("boss_battery_assault_aura_datadriven"):GetLevel()
     if level>1 then
       thisEntity:FindAbilityByName("boss_battery_assault_aura_datadriven"):SetLevel(level-1)  --其实是增强了，弹幕光环的效果
     end
     TecMazeCreater.boom_interval=TecMazeCreater.boom_interval-0.01
     TecMazeCreater.boom_damage=TecMazeCreater.boom_damage+20
     thisEntity.upgrade_time=GameRules:GetGameTime()
  end


  return behaviorSystem:Think()
end

--------------------------------------------------------------------------------------------------------
BehaviorNone = {}
function BehaviorNone:Evaluate()
  return 2 -- must return a value > 0, so we have a default 控制大方向，往一个最近的英雄处靠近
end

function BehaviorNone:Begin()
  self.target=nil
  self.endTime = GameRules:GetGameTime() + 1
  local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
    if #allEnemies > 0 then
      local minDistance = 10000000
      for _,enemy in pairs(allEnemies) do
        local distance = ( thisEntity:GetOrigin() - enemy:GetOrigin() ):Length()
        if distance < minDistance then
          minDistance=distance
                  self.target=enemy
        end
      end
    end


  if self.target then 
    self.order =
    {
      UnitIndex = thisEntity:entindex(),
      OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
      Position =  self.target:GetOrigin()
    }
  else
    self.order =
    {
      UnitIndex = thisEntity:entindex(),
      OrderType = DOTA_UNIT_ORDER_STOP
    }
  end
end
 BehaviorNone.Continue=BehaviorNone.Begin
--------------------------------------------------------------------------------------------------------
POSITIONS_retreat = Entities:FindAllByName( "rattlewaypoint_*" )
for i = 1, #POSITIONS_retreat do
  POSITIONS_retreat[i] = POSITIONS_retreat[i]:GetOrigin()
end

BehaviorRun = {}

function BehaviorRun:Evaluate()
  if self.oreder==nil then
   self.order =
     {
     UnitIndex = thisEntity:entindex(),
     OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
     Position = POSITIONS_retreat[ RandomInt(1, #POSITIONS_retreat) ],
     }
  end
  if thisEntity.maze_switch and thisEntity.maze_switch==1 or thisEntity.maze_switch==3 then
      --print("we in this 3")
      return 3 -- must return a value > 0, so we have a default
  else
      --print("we in this 1")
      return 1
  end
end

function BehaviorRun:Initialize()
end

function BehaviorRun:Begin()
  self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorRun:Continue()
  self.endTime = GameRules:GetGameTime() + 1
end

function BehaviorRun:Think(dt)
  local currentPos = thisEntity:GetOrigin()
  currentPos.z = 0
  
  if self.order then
    if ( self.order.Position - currentPos ):Length() < 200 then
     self.order.Position = POSITIONS_retreat[ RandomInt(1, #POSITIONS_retreat) ]
    end
  end
end

--------------------------------------------------------------------------------------------------------

BehaviorLaunchMissile = {}

function BehaviorLaunchMissile:Evaluate()
  self.ability = thisEntity:FindAbilityByName("rattletrap_spawn_laser_turret")
    desire=0
  if self.ability and self.ability:IsFullyCastable() then
        desire = 5
    self.order =
    {
        OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
        UnitIndex = thisEntity:entindex(),  
        AbilityIndex = self.ability:entindex()
    }
  end
  return desire
end

function BehaviorLaunchMissile:Begin()
  self.endTime = GameRules:GetGameTime() + 1.0
end

BehaviorLaunchMissile.Continue = BehaviorLaunchMissile.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorLaunchMissile:Think(dt)
  if not self.ability:IsFullyCastable() and not self.ability:IsInAbilityPhase() then
    self.endTime = GameRules:GetGameTime()
  end
end
