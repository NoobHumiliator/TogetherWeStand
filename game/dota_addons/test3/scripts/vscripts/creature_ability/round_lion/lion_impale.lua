function LaunchImpale(keys)

    local caster=keys.caster
    local ability=keys.ability
    local ability_level = ability:GetLevel()-1
    local spike_speed = ability:GetLevelSpecialValueFor("spike_speed", ability_level)


    local index= tonumber(keys.Index) --尖刺的编号
    if caster.lion_impale_angel==nil then
       caster.lion_impale_angel={}
       caster.lion_impale_safe_angel=RandomInt(0,360)
    end
    if caster.lion_impale_angel[index] ==nil then
       caster.lion_impale_angel[index]=caster.lion_impale_safe_angel+index*55  --随机选取安全角度
    else 
       caster.lion_impale_angel[index]=caster.lion_impale_angel[index]+15 --每次尖刺递增5度
    end
    local result = {}
    local casterOrigin  = caster:GetAbsOrigin()
    local angel=caster.lion_impale_angel[index]
    local vector=GetGroundPosition(Vector(casterOrigin.x+math.sin(math.rad(angel))*5500,casterOrigin.y+math.cos(math.rad(angel))*5500,0),nil) 
    local velocity=vector:Normalized() * spike_speed

    local info = 
	{
		Ability = ability,
        EffectName = "particles/units/heroes/hero_lion/lion_spell_impale.vpcf",
        --iMoveSpeed = 850,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = 5500,
        fStartRadius = 75,
        fEndRadius = 75,
        Source = caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
	    bDeleteOnHit = false,
		vVelocity = velocity,
	}

    local projectile = ProjectileManager:CreateLinearProjectile(info)

    
end


function ResetLauchAngle(keys)

   local caster=keys.caster
   caster.lion_impale_angel=nil
    
end