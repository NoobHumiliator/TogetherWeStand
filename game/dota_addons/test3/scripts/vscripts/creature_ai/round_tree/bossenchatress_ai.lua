--[[
小鹿BOSS的AI
]]


require( "ai_core" )
require("addon_game_mode")

behaviorSystem = {} -- create the global so we can assign to it

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone , BehaviorLight_Strike , BehaviorFreeze  } ) 
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
	thisEntity:RemoveModifierByName("modifier_razor_eye_of_the_storm_armor")
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
BehaviorLight_Strike = {}

function BehaviorLight_Strike:Evaluate()
	self.strikeAbility = thisEntity:FindAbilityByName("boss_nature_wrath")    --放大
	local target
	local desire = 0

	-- let's not choose this twice in a row
	if AICore.currentBehavior == self then return desire end

	if self.strikeAbility and self.strikeAbility:IsFullyCastable() then      
		target = AICore:RandomEnemyHeroInRange( thisEntity, 3000)
	end

	if target then
		desire = 6
		self.target = target
	else
		desire = 1
	end

	return desire
end

function BehaviorLight_Strike:Begin()
	self.endTime = GameRules:GetGameTime() + 1
    self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
		AbilityIndex = self.strikeAbility:entindex(),
		TargetIndex = self.target:entindex()
	}
	 print("now wrath level is"..self.strikeAbility:GetLevel())  
end 

BehaviorLight_Strike.Continue = BehaviorLight_Strike.Begin --if we re-enter this ability, we might have a different target; might as well do a full reset

--------------------------------------------------------------------------------------------------------
BehaviorFreeze = {}         ----------------------------------------------------------降级

function BehaviorFreeze:Evaluate()
	local desire = 1
	-- let's not choose this twice in a row
	thisEntity:RemoveModifierByName("modifier_razor_eye_of_the_storm_armor")
	if currentBehavior == self then return desire end
	self.freezeAbility = thisEntity:FindAbilityByName( "boss_enchantress_elder_killed" )
	if self.freezeAbility and self.freezeAbility:IsFullyCastable() and thisEntity:GetContext("use_cut_elf_number")~=nil and thisEntity:GetContext("use_cut_elf_number")>=1 then
			desire = 11
	end	
	return desire
end

function BehaviorFreeze:Begin()
	self.endTime = GameRules:GetGameTime() + 1
	GameRules:SendCustomMessage("#elder_killer_dbm", 0, 0)
	self.order =
	{
		UnitIndex = thisEntity:entindex(),
		OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
		AbilityIndex = self.freezeAbility:entindex()
	}
end

BehaviorFreeze.Continue = BehaviorFreeze.Begin
----------------------------------------------------------------------------------------------------------------------------------------------
AICore.possibleBehaviors = { BehaviorNone , BehaviorLight_Strike , BehaviorFreeze }

