require( "libraries/physics")

function KnockBack ( event )
	local npc = event.target
	local dir = 1
	local jumpdur = 0.5
	local vec
    if event.minrange and (event.caster:GetAbsOrigin() - event.target:GetAbsOrigin()):Length() < event.minrange then
        return
    end
	if event.moltenlava then
		vec = -event.target_points[1]+npc:GetAbsOrigin()
	else
		if event.notarget then
			vec = event.caster:GetForwardVector():Normalized()*event.notarget
		else
			if npc == nil then
				vec = event.target_points[1]-event.caster:GetAbsOrigin()
			elseif event.random ~= nil then
				local vec1 = RandomVector(1.0)
				vec = Vector(vec1[1],vec1[2],0)
				if not event.dontface then
					npc:SetForwardVector(vec)
				end
            elseif event.forward then
                local vec1 = npc:GetForwardVector()
                vec = Vector(vec1[1],vec1[2],0)
                if not event.dontface then
                    npc:SetForwardVector(vec)
                end
			else
				if event.aoepull then
					vec = npc:GetAbsOrigin()-event.target_points[1]
				else
					vec = npc:GetAbsOrigin()-event.caster:GetAbsOrigin()
				end
			end
		end
	end

	vec[3] = 0

	-- if its feral charge
	if event.charge ~= nil then
		npc = event.caster
	end

	-- if its the ranger
	if event.chargeranger ~= nil then
		dir = -1
		npc = event.caster
	end
	-- if its feral crush (prot warrior)
	if event.crush then
		npc = event.caster
	end

    local overtimefactor = 1.0
    if event.increaseovertime then
        if npc.forceincreaseovertime then
            npc.forceincreaseovertime = npc.forceincreaseovertime + event.increaseovertime
        else
            npc.forceincreaseovertime = event.increaseovertime
        end
        overtimefactor = overtimefactor + npc.forceincreaseovertime
    end

	Physics:Unit(npc)
	npc:SetPhysicsFriction(0.0)

	if event.fixedforce then
		vec = vec:Normalized()*event.fixedforce*0.85
		npc:SetPhysicsFriction(0.08)
	else
		vec = vec - vec:Normalized()*150
	end

	-- if its deathgrip
	if event.inversed ~= nil then
		dir = -1
	end

	if npc:GetUnitLabel() == "tower" or npc.forceimune then
 		return
	end

	
	npc:PreventDI(false)
	npc:SetAutoUnstuck(true)
	npc:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
	npc:FollowNavMesh(true)
	npc:SetPhysicsVelocityMax(2500)
	if event.friction then
		npc:SetPhysicsFriction(event.friction)
        --print("friction" .. event.friction)
	end
	npc:Hibernate(false)
	npc:SetGroundBehavior(PHYSICS_GROUND_LOCK)
	vec = vec * 2.0 * dir * overtimefactor
	if event.upintheair and event.upintheair > 0 then
		npc:SetGroundBehavior(PHYSICS_GROUND_NOTHING)
		npc:SetNavCollisionType(PHYSICS_NAV_NOTHING)
		vec[3] = 300*event.upintheair
		Timers:CreateTimer(jumpdur/2, function()
			npc:AddPhysicsVelocity(Vector(0,0,-300*event.upintheair*2))
		end)
	end

	if npc.isunderforce then
		npc.isunderforce = npc.isunderforce + 1
	else
		npc.isunderforce = 1
	end

	npc:SetPhysicsVelocity(vec)
    
	Timers:CreateTimer(jumpdur, function()
		if npc.isunderforce <= 1 then
            if not event.forever then
                npc:SetPhysicsVelocity(Vector(0,0,0))
                npc:SetNavCollisionType(PHYSICS_NAV_BOUNCE)
                npc:Hibernate(true)
            end
		end
		npc.isunderforce = npc.isunderforce - 1
	end)

	Timers:CreateTimer(2.0, function()
		local table = {}
		table.Duration = 0.02
        if event.ability and npc and not npc:IsNull() and not event.ability:IsNull() then
	   	   event.ability:ApplyDataDrivenModifier(npc, npc, "modifier_phased", table)
        end
	end)
end