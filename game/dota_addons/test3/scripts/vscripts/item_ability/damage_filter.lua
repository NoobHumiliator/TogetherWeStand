
sp_exempt_table = {}
sp_exempt_table["necrolyte_reapers_scythe_datadriven"]=true
sp_exempt_table["huskar_life_break"]=true
sp_exempt_table["self_huskar_life_break"]=true
sp_exempt_table["zuus_static_field"]=true
sp_exempt_table["death_prophet_spirit_siphon"]=true
sp_exempt_table["elder_titan_earth_splitter"]=true
sp_exempt_table["winter_wyvern_arctic_burn"]=true
sp_exempt_table["doom_bringer_infernal_blade"]=true
sp_exempt_table["phoenix_sun_ray"]=true


function CHoldoutGameMode:DamageFilter(damageTable)
   if damageTable and damageTable.entindex_attacker_const then
	  local attacker = EntIndexToHScript(damageTable.entindex_attacker_const)
	  local victim = EntIndexToHScript(damageTable.entindex_victim_const)
	  if attacker:GetTeam()==DOTA_TEAM_GOODGUYS then
	        if damageTable.entindex_inflictor_const ~=nil then
	           local ability=EntIndexToHScript(damageTable.entindex_inflictor_const)
	           if attacker.sp~=nil and  damageTable.damagetype_const==2  and  not sp_exempt_table[ability:GetAbilityName()]  then
	           	 if ability:IsToggle() or ability:IsPassive() then
	              damageTable.damage=damageTable.damage*(1+attacker.sp*0.3*attacker:GetIntellect()/100)
	              --print("toggle or passive ability name is"..ability:GetAbilityName())
	             else
	              damageTable.damage=damageTable.damage*(1+attacker.sp*attacker:GetIntellect()/100)
	             end
	           end
	        else
	           if attacker.sp~=nil and  damageTable.damagetype_const==2 then
	             damageTable.damage=damageTable.damage*(1+attacker.sp*attacker:GetIntellect()/100)
	           end
	        end
	      if self.map_difficulty==1 then 
	      	damageTable.damage=damageTable.damage*1.4
	      end
	      if self.map_difficulty==3 then
	      	damageTable.damage=damageTable.damage*0.7
	      end
          if attacker then
          	local playerid=nil
          	if attacker:GetOwner() then
          		playerid=attacker:GetOwner():GetPlayerID()
          	end
          	if playerid==nil then
          		 print(attacker:GetUnitName().."has no owner")
          	end
          	if self._currentRound and playerid then
          		self._currentRound._vPlayerStats[playerid].nTotalDamage=self._currentRound._vPlayerStats[playerid].nTotalDamage+damageTable.damage
          	end
          end
      end
      if attacker:GetTeam()==DOTA_TEAM_BADGUYS then
      	 if self.map_difficulty==1 then 
      	  damageTable.damage=damageTable.damage*0.5
      	 end
      	 if self.map_difficulty==3 then
	      	damageTable.damage=damageTable.damage*1.5
	     end
      end
   end
   return true
end
