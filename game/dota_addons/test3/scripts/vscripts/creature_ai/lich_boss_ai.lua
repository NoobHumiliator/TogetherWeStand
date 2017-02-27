--[[
Lich BOSS的AI
]]


require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorStatic_Link,BehaviorIce_Armor,BehaviorDeath_Decay} ) 
      local frostArmorAbility=thisEntity:FindAbilityByName("lich_creature_frost_armor") 
      frostArmorAbility:SetLevel(2)  --高级的冰甲
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
	self.staticlinkAbility = thisEntity:FindAbilityByName("lich_boss_nova")    
	local desire = 0
	local range = self.staticlinkAbility:GetCastRange()
	local target = AICore:RandomEnemyHeroInRangeNotIllusion(thisEntity,range)   --范围对内随机非幻象英雄使用死亡缠绕
	if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() and target then   
		desire = 6
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorStatic_Link:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = self.target:entindex(),
		AbilityIndex = self.staticlinkAbility:entindex()
	}
	if thisEntity:IsAlive() then
	  Notifications:BossAbilityDBM("lich_boss_nova")
	end
end 

BehaviorStatic_Link.Continue = BehaviorStatic_Link.Begin

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
	self.icearmorAbility = thisEntity:FindAbilityByName("lich_creature_frost_armor") 
	local desire = 0
	local range = self.icearmorAbility:GetCastRange()
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, 0, false )
	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local distanceToEnemy = (thisEntity:GetOrigin() - enemy:GetOrigin()):Length()
		local HP = enemy:GetHealth()
		if enemy:IsAlive() and not enemy:HasModifier('modifier_imba_frost_armor') and (minHP == nil or HP < minHP) and distanceToEnemy < range then
			minHP = HP
			target = enemy
		end
	end
    
    self.target=target
    
	if self.icearmorAbility and self.icearmorAbility:IsFullyCastable() and target then   --找到血量最低，并且身上没有冰甲的单位
		desire = 5
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
end 

BehaviorIce_Armor.Continue = BehaviorIce_Armor.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

function BehaviorIce_Armor:Think(dt)
	if self.target  and not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
BehaviorDeath_Decay = {}

function BehaviorDeath_Decay:Evaluate()
	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end
	self.staticlinkAbility = thisEntity:FindAbilityByName("lich_boss_death_and_dacay")    
	local desire = 0
	local range = self.staticlinkAbility:GetCastRange()
	local target = AICore:RandomEnemyHeroInRangeNotIllusion(thisEntity,range)   --范围对内随机非幻象英雄 死亡凋零
	if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() and target then   
		desire = 4
		self.targetPoint=target:GetOrigin()
	else
		desire = 1
	end
    self.target=target

	return desire
end

function BehaviorDeath_Decay:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	self.order =
	{
	    UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
		AbilityIndex = self.staticlinkAbility:entindex(),
		Position = self.targetPoint
	}
	if thisEntity:IsAlive() then
	   Notifications:BossAbilityDBM("lich_boss_death_and_dacay")
	end
end 

BehaviorDeath_Decay.Continue = BehaviorDeath_Decay.Begin

function BehaviorDeath_Decay:Think(dt)
	if self.target  and not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorStatic_Link,BehaviorIce_Armor,BehaviorDeath_Decay}

