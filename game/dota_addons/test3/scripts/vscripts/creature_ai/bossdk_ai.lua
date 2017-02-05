--[[
巫妖的AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone ,  BehaviorStatic_Link,BehaviorIce_Armor,BehaviorPlasma_Field} ) 
    end
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
       return behaviorSystem:Think()
end


--------------------------------------------------------------------------------------------------------
BehaviorNone = {}
function BehaviorNone:Evaluate()
	return 2 -- must return a value > 0, so we have a default 控制大方向，往一个最近的英雄处靠近
end

function BehaviorNone:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.target=nil
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


	if self.target and self.target:IsAlive() then
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
BehaviorStatic_Link = {}

function BehaviorStatic_Link:Evaluate()
	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end
	self.staticlinkAbility = thisEntity:FindAbilityByName("holdout_mist_coil")    --对技能进行定义
	local desire = 0
	local range = self.staticlinkAbility:GetCastRange()
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (thisEntity:GetOrigin() - enemy:GetOrigin()):Length()
		if enemy:IsAlive() and enemy:IsStunned() and distanceToEnemy < range then
			target = enemy
		end
	end
         
	if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() and target then   --找到被小强晕的单位，上死亡缠绕
		desire = 4
		self.target = target
            self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			UnitIndex = thisEntity:entindex(),
			TargetIndex = target:entindex(),
			AbilityIndex = self.staticlinkAbility:entindex()
		}
	else
		desire = 1
	end

	return desire
end

function BehaviorStatic_Link:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	--[[self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
        TargetIndex = self.target:entindex(),
		AbilityIndex = self.staticlinkAbility:entindex()
	}
    --]]
end 

BehaviorStatic_Link.Continue = BehaviorStatic_Link.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorStatic_Link:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
BehaviorIce_Armor = {}

function BehaviorIce_Armor:Evaluate()
	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end
	self.icearmorAbility = thisEntity:FindAbilityByName("holdout_mist_coil")    --对技能进行定义
	local desire = 0
	local range = self.icearmorAbility:GetCastRange()
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (thisEntity:GetOrigin() - enemy:GetOrigin()):Length()
		local HP = enemy:GetHealth()
		if enemy:IsAlive() and (minHP == nil or HP < minHP) and distanceToEnemy < range then
			minHP = HP
			target = enemy
		end
	end
         
	if self.icearmorAbility and self.icearmorAbility:IsFullyCastable() and target and (target:GetHealth()<(target:GetMaxHealth()/3))  then   --找到血量最低的盟友，且低于百分之33的盟友，奶起来
		desire = 5
		self.target = target
            self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			UnitIndex = thisEntity:entindex(),
			TargetIndex = target:entindex(),
			AbilityIndex = self.icearmorAbility:entindex()
		}
	else
		desire = 1
	end

	return desire
end

function BehaviorIce_Armor:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	--[[self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
        TargetIndex = self.target:entindex(),
		AbilityIndex = self.staticlinkAbility:entindex()
	}
    --]]
end 

BehaviorIce_Armor.Continue = BehaviorIce_Armor.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorIce_Armor:Think(dt)
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
BehaviorPlasma_Field = {}

function BehaviorPlasma_Field:Evaluate()
	local desire = 1
	
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.plasmaAbility = thisEntity:FindAbilityByName( "creature_summon_undead" )
	
	if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRange( thisEntity, 450 )
		if self.target then
			desire = 3
		end
	end	
	return desire
end

function BehaviorPlasma_Field:Begin()
	self.endTime = GameRules:GetGameTime() + 2.2	
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.plasmaAbility:entindex()
	}

end

BehaviorPlasma_Field.Continue = BehaviorPlasma_Field.Begin
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorStatic_Link,BehaviorIce_Armor,BehaviorPlasma_Field}

