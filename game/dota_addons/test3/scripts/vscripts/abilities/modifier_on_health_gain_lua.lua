require("util")
modifier_on_health_gain_lua = class({})




function modifier_on_health_gain_lua:DeclareFunctions()
	local funcs = {
	MODIFIER_EVENT_ON_HEALTH_GAINED,
  MODIFIER_EVENT_ON_HEAL_RECEIVED
}
  return funcs
end


function modifier_on_health_gain_lua:IsHidden()
  return true
end



function modifier_on_health_gain_lua:OnHealthGained( keys )  --非过量 
	if IsServer() then
	  local parent = self:GetParent()
    if not parent:IsSummoned() then
       local healer=keys.unit
       local gain=keys.gain
       local necroticModifierName = "modifier_necrotic_stack"
       local actual_gain=gain
       --print("parent: "..parent:GetUnitName().." healer: "..healer:GetUnitName().." gain ".. gain)

       if parent:HasModifier( necroticModifierName ) then
          local necrotic_stack = parent:GetModifierStackCount( necroticModifierName, nil)
          local damage_table = {}
          if necrotic_stack>100 then
          	necrotic_stack=100
          end 
          --local damage= gain* ( necrotic_stack * 0.02)
          local damage= gain* (necrotic_stack * 0.01)
          actual_gain=gain-damage
       	  damage_table.attacker = self:GetCaster()
		      damage_table.victim = parent
		      damage_table.damage_type = DAMAGE_TYPE_PURE
		      damage_table.ability = self:GetAbility()
		      damage_table.damage = damage
		      damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
		      ApplyDamage(damage_table)     
       end
  
       if healer and healer:GetTeam()==DOTA_TEAM_GOODGUYS  then
          local playerid=nil
          if healer:GetOwner() then
            playerid=healer:GetOwner():GetPlayerID()
          end
          if playerid==nil then
           print("healer"..healer:GetUnitName().."has no owner")
          end
          local healerMultiple=0
          if healer:HasModifier("modifier_item_healer_3") then
            healerMultiple =1.5
          else
            if healer:HasModifier("modifier_item_healer_2") then
              healerMultiple =1
            else
              if healer:HasModifier("modifier_item_healer_1") then
                healerMultiple=0.5
              end
            end
          end
          if healerMultiple>0 then
            local bonus_heal=math.ceil(actual_gain*healerMultiple*healer:GetIntellect()/100)
            local current_health=parent:GetHealth()
            local max_health=parent:GetMaxHealth()
            if (current_health+bonus_heal)>max_health then
                bonus_heal=max_health-current_health
                parent:SetHealth(parent:GetMaxHealth())
            else
                local set_health=current_health+bonus_heal
                parent:SetHealth(set_health)
            end
            actual_gain=actual_gain+bonus_heal
          end
          --统计治疗量
          local playerid=nil
          if healer:GetOwner() then
            playerid=healer:GetOwner():GetPlayerID()
          end
          if playerid==nil then
           print("healer"..healer:GetUnitName().."has no owner")
          end
          local game_mode=GameRules:GetGameModeEntity().CHoldoutGameMode
          if game_mode._currentRound and playerid then
           game_mode._currentRound._vPlayerStats[playerid].nTotalHeal=game_mode._currentRound._vPlayerStats[playerid].nTotalHeal+actual_gain
          end
          --统计结束
       end
       if healer==nil then
        print("healer is null gain: "..gain)
       end

      if parent.heal_absorb~=nil then
         local damage=math.min(parent.heal_absorb, actual_gain)
         print("damage: "..damage)
         parent.heal_absorb=parent.heal_absorb-damage

         local damage_table = {}
          damage_table.attacker = self:GetCaster()
          damage_table.victim = parent
          damage_table.damage_type = DAMAGE_TYPE_PURE
          damage_table.ability = self:GetAbility()
          damage_table.damage = damage
          damage_table.damage_flags = DOTA_DAMAGE_FLAG_HPLOSS
          if parent:GetHealth()/parent:GetMaxHealth()<0.99 then
             ApplyDamage(damage_table)  --满血不造成伤害
          end
         if parent.heal_absorb<=0 then
            parent:RemoveModifierByName("modifier_overflow_stack")
            parent.heal_absorb=nil
         else
            local stack=math.floor(parent.heal_absorb/100)
            ability:ApplyDataDrivenModifier( parent, parent, "modifier_overflow_stack", {} )
            parent:SetModifierStackCount( "modifier_overflow_stack", ability, stack )
         end
      end 
    end --是否召唤生物
	end --IsServer
end


function modifier_on_health_gain_lua:OnHealReceived( keys ) --过量
  if IsServer() then
     local parent = self:GetParent()
     local healer=keys.unit
     local gain=keys.gain
     local ability=self:GetAbility()
     --print("OnHealReceived parent: "..parent:GetUnitName().." healer: "..healer:GetUnitName().." gain ".. gain)
     local overflow=gain+parent:GetHealth()-parent:GetMaxHealth()
     if parent:HasModifier("modifier_overflow_show") and overflow>0 then
       if parent.heal_absorb==nil then
          parent.heal_absorb=gain
       else
          parent.heal_absorb=parent.heal_absorb+gain
          local stack=math.floor(parent.heal_absorb/100)
          ability:ApplyDataDrivenModifier( parent, parent, "modifier_overflow_stack", {} )
          parent:SetModifierStackCount( "modifier_overflow_stack", ability, stack )
       end
     end
  end
end