--[[
DK BOSS的AI
]]

dk_heal_table={}
dk_heal_table["death_knight_boss"]=true
dk_heal_table["crypt_lord_boss"]=true
dk_heal_table["lich_boss"]=true




require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorStatic_Link,BehaviorIce_Armor,BehaviorPlasma_Field,BehaviorDeath_Pact} )
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
	local allEnemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false )
		if #allEnemies > 0 then
			self.target = allEnemies[1]
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
	self.staticlinkAbility = thisEntity:FindAbilityByName("death_knight_boss_mist_coil")
	local desire = 0
	local range = self.staticlinkAbility:GetCastRange()
	local target = AICore:RandomEnemyHeroInRangeNotIllusion(thisEntity,range)   --范围对内随机非幻象英雄使用死亡缠绕
	if self.staticlinkAbility and self.staticlinkAbility:IsFullyCastable() and target then
		desire = 4
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
	  Notifications:BossAbilityDBM("death_knight_boss_mist_coil")
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
	self.icearmorAbility = thisEntity:FindAbilityByName("death_knight_boss_mist_coil")
	local desire = 0
	local range = self.icearmorAbility:GetCastRange()
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO, 0, FIND_ANY_ORDER, false )
	local minHP = nil
	local target = nil

	for _,enemy in pairs(enemies) do
		local HP = enemy:GetHealth()
		if enemy:IsAlive() and  dk_heal_table[enemy:GetUnitName()] and (minHP == nil or HP < minHP) then
			minHP = HP
			target = enemy
		end
	end

	if self.icearmorAbility and self.icearmorAbility:IsFullyCastable() and target and (target:GetHealth()<(target:GetMaxHealth()/2)) then   --找到血量最低并且生命小于一半的本关BOSS单位，奶起来
		desire = 5
        self.order =
		{
			OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
			UnitIndex = thisEntity:entindex(),
			TargetIndex = target:entindex(),
			AbilityIndex = self.icearmorAbility:entindex()
		}
		if thisEntity:IsAlive() then
		  Notifications:BossAbilityDBM("death_knight_boss_mist_coil")
		end
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
	if not self.target:IsAlive() then
		self.endTime = GameRules:GetGameTime()
		return
	end
end
--------------------------------------------------------------------------------------------------------
BehaviorPlasma_Field = {}

function BehaviorPlasma_Field:Evaluate()
	local desire = 1

	if currentBehavior == self then return desire end
	self.plasmaAbility = thisEntity:FindAbilityByName( "death_knight_boss_animate_dead" )

	if self.plasmaAbility and self.plasmaAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRange(thisEntity, 600)
		if self.target then
			desire = 6
		end
	end
	return desire
end

function BehaviorPlasma_Field:Begin()
	self.endTime = GameRules:GetGameTime() + 1.0
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.plasmaAbility:entindex()
	}

end

BehaviorPlasma_Field.Continue = BehaviorPlasma_Field.Begin
--------------------------------------------------------------------------------------------------------
BehaviorDeath_Pact = {}

function BehaviorDeath_Pact:Evaluate()
	local desire = 1

	if currentBehavior == self then return desire end

	self.ability = thisEntity:FindAbilityByName( "death_knight_boss_death_pact" )
	local range = self.ability:GetCastRange()

	if self.ability and self.ability:IsFullyCastable() then
		self.target = AICore:RandomNormalFriendCreepInRange(thisEntity, range)
		if self.target then
			print(self.target:GetUnitName())
			desire = 3
		end
	end
	return desire
end

function BehaviorDeath_Pact:Begin()
	self.endTime = GameRules:GetGameTime() + 1.0
	self.order =
	{
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		UnitIndex = thisEntity:entindex(),
		TargetIndex = self.target:entindex(),
		AbilityIndex = self.ability:entindex()
	}

end

BehaviorDeath_Pact.Continue = BehaviorDeath_Pact.Begin
--------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorStatic_Link,BehaviorIce_Armor,BehaviorPlasma_Field,BehaviorDeath_Pact}

