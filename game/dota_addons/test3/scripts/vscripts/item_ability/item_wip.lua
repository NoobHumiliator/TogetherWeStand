-- Used to keep track of projectiles after creation
ProjectileHolder = {} 

--This function will create the 7 projectiles to volly, in a 57.5 degree cone
function item_volly(args)
	local caster = args.caster
	--A Liner Projectile must have a table with projectile info
	local info = 
	{
		Ability = args.ability,
        EffectName = args.EffectName,
        iMoveSpeed = args.MoveSpeed,
        vSpawnOrigin = caster:GetAbsOrigin(),
        fDistance = args.FixedDistance,
        fStartRadius = args.StartRadius,
        fEndRadius = args.EndRadius,
        Source = args.caster,
        bHasFrontalCone = false,
        bReplaceExisting = false,
        iUnitTargetTeam = DOTA_UNIT_TARGET_TEAM_ENEMY,
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_NONE,
        iUnitTargetType = DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		    bDeleteOnHit = true,
		    vVelocity = 0.0,
	}
	for i=-3.6,3.6,0.6 do
		info.vVelocity = RotatePosition(Vector(0,0,0), QAngle(0,i*RandomInt( 1, 100),0), caster:GetForwardVector()) * (args.MoveSpeed*RandomInt(1, 100)+150)
		projectile = ProjectileManager:CreateLinearProjectile(info)
	end
end
--This Function determines the effects when a volly projectile hits a hero
function item_vollyHit(args)

	local target = args.target
	local caster = args.caster
	local totalDamage = args.BonusDamage 
	
		local damageTable = {
			victim = target,
			attacker = caster,
			damage = totalDamage,
			damage_type = DAMAGE_TYPE_PHYSICAL,}
			--PrintTable(damageTable)
		ApplyDamage(damageTable)	
end


function item_big_blow_dot( keys )
    local caster = keys.caster
    local target = nil
    local c_team = caster:GetTeam()
    local allEnemies = FindUnitsInRadius( c_team, caster:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )  --全地图所有英雄
		if #allEnemies > 0 then
			for _,enemy in pairs(allEnemies) do
                  target=enemy
                      if target:GetContext("big_blow_dot")==nil then    --dot计数器初始化
                         target:SetContextNum("big_blow_dot", 0, 0) 
                      end
                       target:SetContextNum("big_blow_dot", target:GetContext("big_blow_dot") + 20, 0)  --每次叠加增加30点伤害
                        local damageTable = 
                        {victim=target,
                        attacker=caster,
                        damage_type=DAMAGE_TYPE_PHYSICAL,
                        damage=target:GetContext("big_blow_dot")}
                        ApplyDamage(damageTable)
			end
		end
end

function item_big_blow_dot_over( keys )
    local caster = keys.caster
    local target = nil
    local c_team = caster:GetTeam()
    local allEnemies = FindUnitsInRadius( c_team, caster:GetOrigin(), nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, 0, 0, false )  --全地图所有英雄
		if #allEnemies > 0 then
			for _,enemy in pairs(allEnemies) do
                  target=enemy
                      if target:GetContext("big_blow_dot")==nil then    --dot计数器初始化
                         target:SetContextNum("big_blow_dot", 0, 0) 
                      end
                      target:SetContextNum("big_blow_dot", 0, 0) ---dot计数器清0
			end
		end
end