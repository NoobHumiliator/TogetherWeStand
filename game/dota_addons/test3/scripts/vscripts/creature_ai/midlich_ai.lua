--[[
巫妖的AI
]]

require( "ai_core" )

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
    behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone ,  BehaviorIce_Armor} ) 
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
--------------------------------------------------------------------------------------------------------
BehaviorIce_Armor = {}

function BehaviorIce_Armor:Evaluate()
	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end
	self.icearmorAbility = thisEntity:FindAbilityByName("lich_creature_frost_armor")    --对技能进行定义
	local desire = 0
	local range = self.icearmorAbility:GetCastRange()
    local enemies = FindUnitsInRadius( DOTA_TEAM_BADGUYS, thisEntity:GetOrigin(), nil, range, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
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
         
	if self.icearmorAbility and self.icearmorAbility:IsFullyCastable() and target then   --找到血量最低的盟友，上冰甲
		desire = 6
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
AICore.possibleBehaviors = { BehaviorNone , BehaviorIce_Armor}

