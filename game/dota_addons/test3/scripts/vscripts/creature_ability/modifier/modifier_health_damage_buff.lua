modifier_health_damage_buff = class({})  --根据血量调整伤害

--------------------------------------------------------------------------------
function modifier_health_damage_buff:OnCreated( kv )
  if IsServer() then
		if self:GetParent() and self:GetParent().IsAlive and self:GetParent():IsAlive() then
		  self.damage_bunus_radio =  (self:GetParent():GetHealth()/self:GetParent():GetMaxHealth())*100 --每个百分比提高1倍伤害  
	    end
	    if self:GetParent().initBaseDamage==nil then
	       self:GetParent().initBaseDamage=(self:GetParent():GetBaseDamageMax()+self:GetParent():GetBaseDamageMin())/2
	    end
		self:StartIntervalThink(0.5)
   end
end
--------------------------------------------------------------------------------
function modifier_health_damage_buff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
        MODIFIER_PROPERTY_MOVESPEED_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_MOVESPEED_BONUS_CONSTANT
	}
	return funcs
end
-------------------------------------------------------------------------
function modifier_health_damage_buff:OnIntervalThink()   --根据血量调整加成
	if IsServer() then
		self.damage_bunus_radio =  (self:GetParent():GetHealth()/self:GetParent():GetMaxHealth())*100 --每个百分比提高1倍伤害  
		self:GetParent():SetBaseDamageMin(self:GetParent().initBaseDamage*self.damage_bunus_radio)
		self:GetParent():SetBaseDamageMax(self:GetParent().initBaseDamage*self.damage_bunus_radio)
	end
end
--------------------------------------------------------------------------------
function modifier_health_damage_buff:GetModifierAttackSpeedBonus_Constant()
	if IsServer() then
		if self.damage_bunus_radio then		   
		    return self.damage_bunus_radio*10
	    else
	       return 1
	    end
    end
end
--------------------------------------------------------------------------------
function modifier_health_damage_buff:GetModifierMoveSpeed_Max( params )  --移动速度无限
    return 5000
end
-------------------------------------------------------------------------------
function modifier_health_damage_buff:GetModifierMoveSpeed_Limit( params ) --移动速度无限
    return 5000
end
--------------------------------------------------------------------------------
function modifier_health_damage_buff:GetModifierMoveSpeedBonus_Constant( params ) --移动速度无限
	if IsServer() then
		if self.damage_bunus_radio then
		    if  self.damage_bunus_radio<40 then   --40%血量到522   基础200 
		    	return self.damage_bunus_radio*8
		    end
		    if self.damage_bunus_radio>40 and self.damage_bunus_radio<80 then --80%血量到1200
		    	return self.damage_bunus_radio*12
		    end
		    if self.damage_bunus_radio>80 then   --如同疯狗
		    	return self.damage_bunus_radio*20
		    end
	    else
	       return 1
	    end
    end
end
-------------------------------------------------------------------------------
function modifier_health_damage_buff:CheckState()
	local fly_flag=false
    
    if self.damage_bunus_radio>95 then
       fly_flag=true
    end

	local state = {
		[MODIFIER_STATE_FLYING_FOR_PATHING_PURPOSES_ONLY] = fly_flag,
	}
	return state
end
------------------------------------------------------------------------------------

function modifier_health_damage_buff:IsHidden()
	return true
end