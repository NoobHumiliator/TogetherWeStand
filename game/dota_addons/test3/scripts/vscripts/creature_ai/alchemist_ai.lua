--[[ Alchemist AI ]]

require( "ai_core" )

function Spawn( entityKeyValues )
	if  thisEntity:GetTeam()==DOTA_TEAM_BADGUYS then
	  thisEntity:SetContextThink( "AIThink", AIThink, 0.25 )
      behaviorSystem = AICore:CreateBehaviorSystem( { BehaviorNone, BehaviorConcoction, BehaviorAcidSpray })
    end
end

function AIThink() -- For some reason AddThinkToEnt doesn't accept member functions
	return behaviorSystem:Think()
end

--------------------------------------------------------------------------------------------------------

BehaviorNone = {}
function BehaviorNone:Evaluate()
	print("4")
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

BehaviorConcoction = {}

function BehaviorConcoction:Evaluate()
	--print( "BehaviorConcoction:Evaluate()" )
	local desire = 0
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.concoctionAbility = thisEntity:FindAbilityByName( "tws_alchemist_unstable_concoction" )
	self.concoctionThrowAbility = thisEntity:FindAbilityByName( "tws_alchemist_unstable_concoction_throw" )
	self.chemicalRageAbility = thisEntity:FindAbilityByName( "tws_alchemist_chemical_rage" )

	for i = 0, DOTA_ITEM_MAX - 1 do
		local item = thisEntity:GetItemInSlot( i )
		if item and item:GetAbilityName() == "item_black_king_bar" then
			self.bkbAbility = item
		end
		if item and item:GetAbilityName() == "item_shivas_guard" then
			self.shivasAbility = item
		end
		if item and item:GetAbilityName() == "item_phase_boots" then
			self.phaseAbility = item
		end
	end
	
	if self.concoctionAbility and self.concoctionAbility:IsFullyCastable() then
		self.target = AICore:ClosestEnemyHeroInRange( thisEntity, self.concoctionAbility:GetCastRange() )
		if self.target and self.target:IsAlive() then
			--print( "Concoction:Evaluate: self.target:entindex() == " .. self.target:entindex() )
			if self.target:IsStunned() then
				desire = 2
			else
				desire = 4
			end
		end
	end
	
	return desire
end

function BehaviorConcoction:Think( dt )

	if self.startConcoctionTime == nil then
		return
	end

	self.target = AICore:ClosestEnemyHeroInRange( thisEntity, self.concoctionAbility:GetCastRange() )

	if self.target and self.target:IsAlive() then

		-- Cast bkb if we can
		if self.bkbAbility and self.bkbAbility:IsFullyCastable() then
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = self.bkbAbility:entindex()
			})
		end

		if GameRules:GetGameTime() >= ( self.startConcoctionTime + 2 ) then
			--print( "it's time to throw Concoction" )
			if self.concoctionThrowAbility and self.concoctionThrowAbility:IsFullyCastable() then
				self.order =
				{
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_TARGET,
					AbilityIndex = self.concoctionThrowAbility:entindex(),
					TargetIndex = self.target:entindex()
				}

				self.startConcoctionTime = nil
				return
			end
		else
			-- cast chemical rage
			if self.chemicalRageAbility and self.chemicalRageAbility:IsFullyCastable() then
				--print( "casting Chemical Rage while doing Concoction stuff" )
				self.order =
				{
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = self.chemicalRageAbility:entindex(),
				}
			end

 			-- chase our target
			ExecuteOrderFromTable({
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
				Position = self.target:GetOrigin()
			})
		end
	end

	-- if we missed our cast window for some reason
	if GameRules:GetGameTime() >= ( self.startConcoctionTime + 5 ) then
		self.startConcoctionTime = nil
		return
	end

end

function BehaviorConcoction:Begin()
	if self.startConcoctionTime == nil then
		--print( "BehaviorConcoction:Begin()" )
		self.endTime = GameRules:GetGameTime() + 5

		if self.concoctionAbility and self.concoctionAbility:IsFullyCastable() then
			self.order =
			{
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
				AbilityIndex = self.concoctionAbility:entindex(),
			}

			self.startConcoctionTime = GameRules:GetGameTime()

			if self.shivasAbility and self.shivasAbility:IsFullyCastable() then
				ExecuteOrderFromTable({
					UnitIndex = thisEntity:entindex(),
					OrderType = DOTA_UNIT_ORDER_CAST_NO_TARGET,
					AbilityIndex = self.shivasAbility:entindex()
				})
			end
		end
	end
end

BehaviorConcoction.Continue = BehaviorConcoction.Begin

--------------------------------------------------------------------------------------------------------

BehaviorAcidSpray = {}

function BehaviorAcidSpray:Evaluate()
	--print( "BehaviorAcidSpray:Evaluate()" )
	local desire = 0
	-- let's not choose this twice in a row
	if currentBehavior == self then return desire end

	self.acidSprayAbility = thisEntity:FindAbilityByName( "tws_alchemist_acid_spray" )
	
	if self.acidSprayAbility and self.acidSprayAbility:IsFullyCastable() then
		self.target = AICore:RandomEnemyHeroInRange( thisEntity, self.acidSprayAbility:GetCastRange() )
		if self.target and self.target:IsAlive() then
			if self.target:IsStunned() then
				desire = 6
			else
				desire = 4
			end
		end
	end
	
	return desire
end

function BehaviorAcidSpray:Begin()
	--print( "BehaviorAcidSpray:Begin()" )
	self.endTime = GameRules:GetGameTime() + 1

	if self.acidSprayAbility and self.acidSprayAbility:IsFullyCastable() then
		--self.target = AICore:RandomEnemyHeroInRange( thisEntity, self.acidSprayAbility:GetCastRange() )
		if self.target and self.target:IsAlive() then
			--print( "casting Acid Spray" )
			local targetPoint = self.target:GetOrigin() + RandomVector( 100 )
			self.order =
			{
				UnitIndex = thisEntity:entindex(),
				OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
				AbilityIndex = self.acidSprayAbility:entindex(),
				Position = targetPoint
			}
		end
	end
end

BehaviorAcidSpray.Continue = BehaviorAcidSpray.Begin

--------------------------------------------------------------------------------------------------------

AICore.possibleBehaviors = { BehaviorNone, BehaviorConcoction, BehaviorAcidSpray }