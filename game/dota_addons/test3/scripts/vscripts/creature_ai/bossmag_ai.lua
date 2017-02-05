--[[
猛犸BOSS的AI
]]


require( "ai_core" )
require("addon_game_mode")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorThrowHook , BehaviorPlasma_Field , BehaviorStrike , BehaviorFreeze} ) 
    end
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end

function CollectRetreatMarkers()
	local result = {}
	local i = 1
	local wp = nil
	while true do
		wp = Entities:FindByName( nil, string.format("waypoint_middle%d", i ) )
		if not wp then
			return result
		end
		table.insert( result, wp:GetOrigin() )
		i = i + 1
	end
end
POSITIONS_retreat = CollectRetreatMarkers()
--------------------------------------------------------------------------------------------------------
BehaviorThrowHook = {}   --冲锋 有目标就desire设为10
function BehaviorThrowHook:Evaluate()
	self.target=nil
	local desire = 1
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end
	self.hookAbility = thisEntity:FindAbilityByName( "charge_to_unit" )
	local targets = FindUnitsInRadius(DOTA_TEAM_BADGUYS, thisEntity:GetOrigin() , nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS+DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false)
	local MaxDistance = 10
	    if #targets > 0 then
           for i,unit in pairs(targets) do                            
                local distance = ( thisEntity:GetOrigin() - unit:GetOrigin() ):Length()
                if distance > MaxDistance and self.hookAbility and self.hookAbility:IsFullyCastable() and not(distance>1000 and unit:IsInvisible()==true) then
				     MaxDistance=distance
                     self.target=unit
                     desire=10
                end
           end
       end   	
	return desire
end

function BehaviorThrowHook:Begin()
	if self.target then 
	 self.endTime = GameRules:GetGameTime() + 2
     Notifications:TopToAll({ability="charge_to_unit"})
	 Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#charge_to_unit_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
     self.order =
	 {
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = self.target:entindex(),
		AbilityIndex = self.hookAbility:entindex()
	 }
	else
		self.order =
		{
			UnitIndex = thisEntity:entindex(),
			OrderType = DOTA_UNIT_ORDER_STOP
		}
	end
end
BehaviorThrowHook.Continue = BehaviorThrowHook.Begin
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
BehaviorPlasma_Field = {}

function BehaviorPlasma_Field:Evaluate()    --两极反转
	local desire = 0
	
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.plasmaAbility = thisEntity:FindAbilityByName( "creature_reverse_polarity" )
	
	if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRange( thisEntity, 3000 )
		if self.target then
			desire = 7
		end
	end	
	return desire
end

function BehaviorPlasma_Field:Begin()
	self.endTime = GameRules:GetGameTime() + 1	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.plasmaAbility:entindex()
	}

end

BehaviorPlasma_Field.Continue = BehaviorPlasma_Field.Begin
--------------------------------------------------------------------------------------------------------
BehaviorStrike = {}

function BehaviorStrike:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("mag_melee_smash")    --对技能进行定义
	local target
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.strikeAbility and self.strikeAbility:IsFullyCastable() then   --技能存在而且处于CD中有蓝
		local range = self.strikeAbility:GetCastRange()
		target = AICore:RandomBadEnemyInRange( thisEntity, range )
	end

	if target then
		desire = 4
		self.target = target
       local targetPoint = self.target:GetOrigin()+RandomVector( 10 )
	   self.point=targetPoint
	else
		desire = 0
	end

	return desire
end

function BehaviorStrike:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	Notifications:TopToAll({ability="mag_melee_smash"})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#mag_melee_smash_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
	self.point= thisEntity:GetOrigin()+thisEntity:GetForwardVector()*(self.strikeAbility:GetCastRange()-10)   --目标方向
    self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.strikeAbility:entindex(),
		Position = self.point
	}
    	--[[self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
        TargetIndex = self.target:entindex(),
		AbilityIndex = self.staticlinkAbility:entindex()
	}
    --]]
end 

BehaviorStrike.Continue = BehaviorStrike.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorStrike:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------

BehaviorFreeze = {}         ----------------------------------------------------------秒杀

function BehaviorFreeze:Evaluate()

	local desire = 1
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end
	local range = 600
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
	local target = nil
	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (thisEntity:GetOrigin() - enemy:GetOrigin()):Length()
		if enemy:IsAlive() and enemy:IsStunned() and distanceToEnemy < range then
			target = enemy
		end
	end
	self.freezeAbility = thisEntity:FindAbilityByName( "mag_kill_them_all" )
	if self.freezeAbility and self.freezeAbility:IsFullyCastable() and target then
			desire = 70
	end	
	return desire
end

function BehaviorFreeze:Begin()
	self.endTime = GameRules:GetGameTime() + 3	
	Notifications:TopToAll({ability="mag_kill_them_all"})
	Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#power_release_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.freezeAbility:entindex()
	}

end
BehaviorFreeze.Continue = BehaviorFreeze.Begin
--------------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorThrowHook , BehaviorPlasma_Field , BehaviorStrike , BehaviorFreeze}

