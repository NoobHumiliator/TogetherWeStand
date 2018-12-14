function BloodLinkCheck( event )
	local caster = event.caster
	local ability = event.ability
	local modifier_regen_health=event.modifier_regen_health
	local link_distance = ability:GetLevelSpecialValueFor( "link_distance" , ability:GetLevel() - 1 )
	if caster.link_flag==nil then
       caster.link_flag=0
	end  
	local friends= FindUnitsInRadius( DOTA_TEAM_BADGUYS, caster:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, 0, 0, false )
	local have_a_friend_flag=0
	local all_died_flag=1
	local alone_flag=1
	for _,friend in pairs(friends) do
		if (caster:GetOrigin()-friend:GetOrigin()):Length()<link_distance  and  friend:HasModifier("modifier_bloodlink_think") and caster.link_flag==0 and friend~=caster then 
		local particleName = "particles/units/heroes/hero_pugna/pugna_life_drain.vpcf"
	    caster.BloodLinkParticle = ParticleManager:CreateParticle(particleName, PATTACH_ABSORIGIN_FOLLOW, caster)
	    ParticleManager:SetParticleControlEnt(caster.BloodLinkParticle, 1, friend, PATTACH_POINT_FOLLOW, "attach_hitloc", friend:GetAbsOrigin(), true)
	    ability:ApplyDataDrivenModifier(caster, caster, modifier_regen_health, {})
	    EmitSoundOn("terrorblade_terr_shards_conjureimage_01",caster)
	    caster.link_flag=1
	    end
	    if (caster:GetOrigin()-friend:GetOrigin()):Length()<link_distance and friend:HasModifier("modifier_bloodlink_think") and friend~=caster then
	     have_a_friend_flag=1
	    end
	    if friend:HasModifier("modifier_invincible_freeze")==false and friend:HasModifier("modifier_bloodlink_think") then
           all_died_flag=0
	    end
	     if friend:HasModifier("modifier_bloodlink_think") and friend~=caster then
          alone_flag=0
	    end
	end
	if have_a_friend_flag==0 and caster.link_flag==1 then
	ParticleManager:DestroyParticle(caster.BloodLinkParticle,false)
	caster:RemoveModifierByName(modifier_regen_health)
    caster.link_flag=0
    end
    if all_died_flag==1 then
       Timers:CreateTimer({
   	              endTime = 0.2,
			      callback =function()
				  caster:ForceKill(true)
				  return nil
			end})
    end
    if alone_flag==1 then
     caster:RemoveAbility('twins_bloodlink_datadriven')
     caster:RemoveModifierByName("modifier_bloodlink_think")
    end
end

function TwinsRespawnActivate( event )
	local caster = event.caster
	local ability = event.ability
	local threshold = ability:GetLevelSpecialValueFor( "hp_threshold" , ability:GetLevel() - 1  )
	if caster:GetHealth() < threshold  then
		ability:ApplyDataDrivenModifier( caster, caster, "modifier_invincible", {})
		caster:EmitSound("Hero_Terrorblade.Sunder.Cast")
	end
end

function RebornParticle( event )
	local caster = event.caster
	local ability = event.ability
	local pfxName = "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn.vpcf"
	local pfx = ParticleManager:CreateParticle( pfxName, PATTACH_ABSORIGIN, caster )
	ParticleManager:SetParticleControlEnt( pfx, 0, caster, PATTACH_POINT_FOLLOW, "follow_origin", caster:GetAbsOrigin(), true )
	ParticleManager:SetParticleControlEnt( pfx, 1, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", caster:GetAbsOrigin(), true )
end
