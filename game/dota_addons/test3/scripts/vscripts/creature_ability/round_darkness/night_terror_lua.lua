LinkLuaModifier( "modifier_night_terror_thinker_lua", "creature_ability/round_darkness/night_terror_lua.lua", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_night_terror_gisp_lua", "creature_ability/round_darkness/night_terror_lua.lua", LUA_MODIFIER_MOTION_NONE )

night_terror_lua = class({})

function night_terror_lua:OnAbilityPhaseStart()
	local caster = self:GetCaster()
	caster:StartGesture(ACT_DOTA_CAST_ABILITY_4)
	return true
end



function night_terror_lua:OnSpellStart() 
	local caster = self:GetCaster()
	local point = self:GetCursorPosition()
	local team_id = caster:GetTeamNumber()
	self.damage_per_tick=self:GetSpecialValueFor( "damage_per_tick" )
	local thinker = CreateModifierThinker(caster, self, "modifier_night_terror_thinker_lua", {}, point, team_id, false)
end

function night_terror_lua:OnProjectileHit( target, location )
	local thinker = self:GetCaster()
	local modifier = thinker:FindModifierByName("modifier_night_terror_thinker_lua")
	local caster = modifier:GetCaster()
    local stun_duration=self:GetSpecialValueFor( "stun_duration" )
    target:AddNewModifier( caster, self, "modifier_night_terror_gisp_lua", { duration = stun_duration } )

    EmitSoundOn( "Hero_Bane.FiendsGrip", target )
	modifier:Destroy()
end

-----------------------------------------------------------------------------------------------------

modifier_night_terror_thinker_lua = class({})

function modifier_night_terror_thinker_lua:OnCreated(event)
	if IsServer() then
		local thinker = self:GetParent()
		local ability = self:GetAbility()
		self.duration = ability:GetSpecialValueFor("duration")
		self.speed = ability:GetSpecialValueFor("speed")
		self.search_radius = ability:GetSpecialValueFor("search_radius")
		thinker:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
		local thinker_pos = thinker:GetAbsOrigin()
		thinker:AddAbility("night_terror_lua")
		thinker:FindAbilityByName("night_terror_lua"):SetLevel(ability:GetLevel())
		self:StartIntervalThink(0.25)
	end
end

function modifier_night_terror_thinker_lua:OnIntervalThink()
	local thinker = self:GetParent()
	local thinker_pos = thinker:GetAbsOrigin()
	if self.init_flag==nil then  --初始化粒子特效、持续时间
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_fiendsgrip_blob.vpcf", PATTACH_OVERHEAD_FOLLOW, thinker)
		self.particle = ParticleManager:CreateParticle("particles/units/heroes/hero_bane/bane_nightmare_slime.vpcf", PATTACH_OVERHEAD_FOLLOW, thinker)
		self.expire = GameRules:GetGameTime() + self.duration
		self.init_flag=true
    end
	if self.duration ~= nil then
		if GameRules:GetGameTime() > self.expire then
			self:Destroy()
		else
			local enemies = FindUnitsInRadius(thinker:GetOpposingTeamNumber(), thinker_pos, nil, self.search_radius, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_CREEP + DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false)
			if enemies[1] then
				self.target = enemies[1]
				self.duration = nil
				self.expire = nil
				self:StartIntervalThink(-1)
				local info = 
					{
					Target = enemies[1],
					Source = thinker,
					Ability = thinker:FindAbilityByName("night_terror_lua"),	
					EffectName = "particles/units/heroes/hero_bane/bane_projectile.vpcf",
					vSourceLoc = thinker_pos,
					bDrawsOnMinimap = false,
					iSourceAttachment = 1,
					iMoveSpeed = self.speed,
					bDodgeable = false,
					bProvidesVision = true,
					iVisionRadius = self.vision_radius,
					iVisionTeamNumber = thinker:GetTeamNumber(),
					bVisibleToEnemies = true,
					flExpireTime = nil,
					bReplaceExisting = false
					}
				ProjectileManager:CreateTrackingProjectile(info)
				ParticleManager:DestroyParticle(self.particle, false)
				EmitSoundOn( "Hero_LifeStealer.Consume", enemies[1] )
			end
		end
	end
end

function modifier_night_terror_thinker_lua:OnDestroy()
	if self.particle then
		ParticleManager:DestroyParticle(self.particle, false)
	end
    if IsServer() then
		UTIL_Remove(self:GetParent())
	end
end

------------------------------------------------------------------------------------------------------
modifier_night_terror_gisp_lua = class({})


function modifier_night_terror_gisp_lua:DeclareFunctions()

	local funcs = {
		MODIFIER_PROPERTY_MAGICDAMAGEOUTGOING_PERCENTAGE
	}
	return funcs
end

function modifier_night_terror_gisp_lua:IsDebuff()
	return true
end

function modifier_night_terror_gisp_lua:OnCreated()
    if IsServer() then
		self:StartIntervalThink(0.25)
	end
end

--------------------------------------------------------------------------------

function modifier_night_terror_gisp_lua:IsStunDebuff()
	return true
end

--------------------------------------------------------------------------------

function modifier_night_terror_gisp_lua:GetEffectName()
	return "particles/units/heroes/hero_bane/bane_fiends_grip.vpcf"
end

--------------------------------------------------------------------------------
function modifier_night_terror_gisp_lua:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
--------------------------------------------------------------------------------
function modifier_night_terror_gisp_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end
--------------------------------------------------------------------------------
function modifier_night_terror_gisp_lua:GetOverrideAnimation( params )
	return ACT_DOTA_FLAIL
end
--------------------------------------------------------------------------------
function modifier_night_terror_gisp_lua:CheckState()
	local state = {
	[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end
---------------------------------------------------------------------------------
function modifier_night_terror_gisp_lua:OnIntervalThink()
	if IsServer() then
		local flDamage = 50.0
		if self:GetCaster() ~=nil  then
			local ability = self:GetCaster():FindAbilityByName("night_terror_lua")
			flDamage = ability:GetSpecialValueFor("damage_per_tick")
	    end
		local damage = {
			victim = self:GetParent(),
			attacker = self:GetCaster(),
			damage = flDamage,
			damage_type = DAMAGE_TYPE_PURE,
			ability = ability
		}

		ApplyDamage( damage )
	end
end
function modifier_night_terror_gisp_lua:GetTexture()
	return "bane_fiends_grip"
end
