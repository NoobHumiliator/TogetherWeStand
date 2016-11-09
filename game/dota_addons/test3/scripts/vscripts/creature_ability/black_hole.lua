require('libraries/notifications')
function BlackHole( event )

	local caster = event.caster
	local ability = event.ability
   
  if caster.fly_switch==nil then
       caster.fly_switch=0 
  end
  if caster:GetHealth() < caster:GetMaxHealth()*0.8  and  caster:GetHealth() > caster:GetMaxHealth()*0.5  and  caster.fly_switch==0 then
      caster.fly_switch=1 

      Notifications:TopToAll({ability= "boss_fly_black_hole_datadriven"})
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#boss_fly_black_hole_datadriven_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
      EmitSoundOn("winter_wyvern_winwyv_attack_08",caster)

      ability:ApplyDataDrivenModifier(caster, caster, "modifier_blue_dragon_boss_fly", {})
      local caster_location=caster:GetAbsOrigin()
      caster_location.z = GetGroundHeight(caster_location,nil)
      local black_hole_vector=Vector(caster_location.x+RandomInt(-800, 800),caster_location.y+RandomInt(-800, 800),0)
      black_hole_vector.z= GetGroundHeight(black_hole_vector,nil)
      local particleName = "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf"
      local particle = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, caster )
      ParticleManager:SetParticleControl(particle, 0, black_hole_vector)
      local speed =0.003
      local damage_increase=1
      Timers:CreateTimer({
            endTime = 0.01,
            callback =function()
            speed=speed+0.0000035
            damage_increase=damage_increase+0.0007
            local enemies= FindUnitsInRadius( DOTA_TEAM_BADGUYS, black_hole_vector, nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
             for _,enemy in pairs(enemies) do
                 local face = (black_hole_vector - enemy:GetAbsOrigin()):Normalized()
                 local length=(black_hole_vector - enemy:GetAbsOrigin()):Length()
                 if  length<250 then
                   local damageTable = {victim=enemy,
                                       attacker=caster,
                                       damage_type=DAMAGE_TYPE_PURE,
                                       damage=enemy:GetMaxHealth()/500*damage_increase}
                   ApplyDamage(damageTable)
                  end                               
                 local vec = face * length *speed
                 enemy:SetOrigin(enemy:GetAbsOrigin() + vec)
             end
            if  caster==nil or (not caster:IsAlive()) or caster.fly_switch>=2 then
                  ParticleManager:DestroyParticle( particle, true )        
                  ParticleManager:ReleaseParticleIndex( particle )
               return  nil
            else
                return 0.01
            end
      end})
   end
   if caster:GetHealth() < caster:GetMaxHealth()*0.5  and  caster:GetHealth() > caster:GetMaxHealth()*0.35  and  caster.fly_switch==1 then
         caster.fly_switch=2
         caster:RemoveModifierByName("modifier_blue_dragon_boss_fly")
   end

   if caster:GetHealth() < caster:GetMaxHealth()*0.35  and  caster.fly_switch==2 then
      caster.fly_switch=3 
      
      Notifications:TopToAll({ability= "boss_fly_black_hole_datadriven"})
      Notifications:TopToTeam(DOTA_TEAM_GOODGUYS, {text="#boss_fly_black_hole_datadriven_dbm_simple", duration=1.5, style = {color = "Azure"},continue=true})
      EmitSoundOn("winter_wyvern_winwyv_attack_08",caster)
      
      ability:ApplyDataDrivenModifier(caster, caster, "modifier_blue_dragon_boss_fly", {})
      local caster_location=caster:GetAbsOrigin()
      caster_location.z = GetGroundHeight(caster_location,nil)
      local black_hole_vector=Vector(caster_location.x+RandomInt(-800, 800),caster_location.y+RandomInt(-800, 800),0)
      black_hole_vector.z= GetGroundHeight(black_hole_vector,nil)
      local particleName = "particles/econ/items/enigma/enigma_world_chasm/enigma_blackhole_ti5.vpcf"
      local particle = ParticleManager:CreateParticle( particleName, PATTACH_WORLDORIGIN, caster )
      ParticleManager:SetParticleControl(particle, 0, black_hole_vector)
      local speed =0.004
      local damage_increase=1
      Timers:CreateTimer({
            endTime = 0.01,
            callback =function()
            speed=speed+0.0000045
            damage_increase=damage_increase+0.001
            local enemies= FindUnitsInRadius( DOTA_TEAM_BADGUYS, black_hole_vector, nil, -1, DOTA_UNIT_TARGET_TEAM_ENEMY,DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, 0, false )
             for _,enemy in pairs(enemies) do
                 local face = (black_hole_vector - enemy:GetAbsOrigin()):Normalized()
                 local length=(black_hole_vector - enemy:GetAbsOrigin()):Length()
                 if  length<250 then
                   local damageTable = {victim=enemy,
                                       attacker=caster,
                                       damage_type=DAMAGE_TYPE_PURE,
                                       damage=enemy:GetMaxHealth()/500*damage_increase}
                   ApplyDamage(damageTable)
                  end                               
                 local vec = face * length *speed
                 enemy:SetOrigin(enemy:GetAbsOrigin() + vec)
             end
            if caster==nil or  (not caster:IsAlive()) then
                    ParticleManager:DestroyParticle( particle, true )        
                    ParticleManager:ReleaseParticleIndex( particle )
               return  nil
            else
                return 0.01
            end
      end})
   end
end
