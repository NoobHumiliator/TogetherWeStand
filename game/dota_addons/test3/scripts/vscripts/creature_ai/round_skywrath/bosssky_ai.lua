--[[
天怒法师BOSS的AI
]]


require( "ai_core" )
require("addon_game_mode")
require('libraries/notifications')

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorStatic_Link , BehaviorLight_Strike , BehaviorThrowHook , BehaviorFreeze , BehaviorLink , BehaviorLaguna_Blade } ) 
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
--------------------------------------------------------------------------------------------------------
BehaviorLight_Strike = {}

function BehaviorLight_Strike:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("creature_sky_stun")    --对技能进行定义
	local target
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.strikeAbility and self.strikeAbility:IsFullyCastable() then   --技能存在而且处于CD中有蓝
		local range = self.strikeAbility:GetCastRange()
		target = AICore:RandomEnemyHeroInRange( thisEntity, range )
	end

	if target then
		desire = 6
		self.target = target
       local targetPoint = self.target:GetOrigin()	
	else
		desire = 1
	end

	return desire
end

function BehaviorLight_Strike:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	--[[self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
        TargetIndex = self.target:entindex(),
		AbilityIndex = self.staticlinkAbility:entindex()
	}
    --]]
    self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = self.strikeAbility:entindex(),
		TargetIndex = self.target:entindex()
	}
end 

BehaviorLight_Strike.Continue = BehaviorLight_Strike.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

--------------------------------------------------------------------------------------------------------
BehaviorStatic_Link = {}

function BehaviorStatic_Link:Evaluate()
	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end
	self.staticlinkAbility = thisEntity:FindAbilityByName("skywrath_mage_mystic_flare_datadriven")    --对技能进行定义
	local desire = 0
	local range = self.staticlinkAbility:GetCastRange()
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (thisEntity:GetOrigin() - enemy:GetOrigin()):Length()
		if enemy:IsAlive() and enemy:IsRooted() and distanceToEnemy < range then
			target = enemy
		end
	end
         
	if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() and target then   --找到被晕的单位，放大
		desire = 7
		self.target = target
        local targetPoint = self.target:GetOrigin()

	    self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.staticlinkAbility:entindex(),
		Position = targetPoint
	}
	else
		desire = 1
	end

	return desire
end

function BehaviorStatic_Link:Begin()
	self.endTime = GameRules:GetGameTime() + 1
end 

BehaviorStatic_Link.Continue = BehaviorStatic_Link.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

--------------------------------------------------------------------------------------------------------
BehaviorThrowHook = {}

function BehaviorThrowHook:Evaluate()       ------飞过去开大
	local desire = 0
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.hookAbility = thisEntity:FindAbilityByName( "fly_to_point" )
	self.bigwindAbility = thisEntity:FindAbilityByName( "big_wind" )

	if self.hookAbility and self.hookAbility:IsFullyCastable() and self.bigwindAbility and self.bigwindAbility:IsFullyCastable() and thisEntity:GetHealth()<(thisEntity:GetMaxHealth()/3) then
			desire = 10     
		else
			desire = 1
	end	
	return desire
end

function BehaviorThrowHook:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.hookAbility:entindex(),
		Position = POSITIONS_retreat[ RandomInt(1, #POSITIONS_retreat) ]
	}

end

BehaviorThrowHook.Continue = BehaviorThrowHook.Begin
--------------------------------------------------------------------------------------------------------
BehaviorFreeze = {}         ----------------------------------------------------------开大

function BehaviorFreeze:Evaluate()
	local desire = 1
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end
	self.freezeAbility = thisEntity:FindAbilityByName( "big_wind" )
	if self.freezeAbility and self.freezeAbility:IsFullyCastable() and  thisEntity:GetHealth()<(thisEntity:GetMaxHealth()/3) and ( POSITIONS_retreat[ RandomInt(1, #POSITIONS_retreat) ] - thisEntity:GetOrigin() ):Length() < 500 then
			desire = 11
	end	
	return desire
end

function BehaviorFreeze:Begin()
	self.endTime = GameRules:GetGameTime() + 15	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.freezeAbility:entindex()
	}

end

BehaviorFreeze.Continue = BehaviorFreeze.Begin
--------------------------------------------------------------------------------------------------------------
BehaviorLaguna_Blade = {}                ---震荡光弹

function BehaviorLaguna_Blade:Evaluate()
	self.bladeAbility = thisEntity:FindAbilityByName("super_concussive")    --对技能进行定义
	local target
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.bladeAbility and self.bladeAbility:IsFullyCastable() then   --技能存在而且处于CD中有蓝
		local range = self.bladeAbility:GetCastRange()
		target = AICore:RandomEnemyHeroInRange( thisEntity, range )
	end

	if target then
		desire = 5
		self.target = target
       
	else
		desire = 1
	end

	return desire
end

function BehaviorLaguna_Blade:Begin()
	self.endTime = GameRules:GetGameTime() + 1
        self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			UnitIndex = thisEntity:entindex(),
			TargetIndex = self.target:entindex(),
			AbilityIndex = self.bladeAbility:entindex()
		}
end 

BehaviorLaguna_Blade.Continue = BehaviorLaguna_Blade.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

----------------------------------------------------------------------------------------------------------------------------------------------
BehaviorLink = {}            -------沉默

function BehaviorLink:Evaluate()
	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end
	self.linkAbility = thisEntity:FindAbilityByName("skywrath_mage_ancient_seal_datadriven")    --对技能进行定义
	local desire = 0
	local range = self.linkAbility:GetCastRange()
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	local minHP = nil          --蓝量
	local target = nil

	for _,enemy in pairs(enemies) do --找一个蓝量最高的单位
		local distanceToEnemy = (thisEntity:GetOrigin() - enemy:GetOrigin()):Length()
		local HP = enemy:GetMana()
		if enemy:IsAlive() and (minHP == nil or HP > minHP) and distanceToEnemy < range then
			minHP = HP
			target = enemy
		end
	end
         
	if self.linkAbility and self.linkAbility:IsFullyCastable() and target then   --找到生命值最少的单位，直接穿
		desire = 4
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorLink:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	
	  if self.target:IsHero() then
	    local playerid= self.target:GetPlayerID()
	    local playername=PlayerResource:GetPlayerName(playerid)
	    Notifications:TopToAll({ability="skywrath_mage_ancient_seal_datadriven"})
	    Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#ancient_seal_simple", duration=1.5, style = {color = "Azure"},continue=true})
      end
	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
        TargetIndex = self.target:entindex(),
		AbilityIndex = self.linkAbility:entindex()
	}
end 

BehaviorLink.Continue = BehaviorLink.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

----------------------------------------------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorStatic_Link , BehaviorLight_Strike , BehaviorThrowHook , BehaviorFreeze , BehaviorLink , BehaviorLaguna_Blade}

