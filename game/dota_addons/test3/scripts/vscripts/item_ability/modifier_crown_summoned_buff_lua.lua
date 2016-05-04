modifier_crown_summoned_buff_lua = class({})
--------------------------------------------------------------------------------

function modifier_crown_summoned_buff_lua:OnCreated( kv )
	--print("hp bonus="..self.bonus_hp)
	if IsServer() then
		local nFXIndex = ParticleManager:CreateParticle( "particles/units/heroes/hero_ogre_magi/ogre_magi_bloodlust_buff.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
		--ParticleManager:SetParticleControlEnt( nFXIndex, 2, self:GetCaster(), PATTACH_POINT_FOLLOW, "attach_head", self:GetCaster():GetOrigin(), true )
		self:AddParticle( nFXIndex, false, false, -1, false, true )
	end
	if self:GetCaster() and self:GetCaster().owner then
		EmitSoundOn( "Hero_OgreMagi.Bloodlust.Target", self:GetCaster() )
	end

end


function modifier_crown_summoned_buff_lua:DeclareFunctions()
	local funcs = {
	MODIFIER_PROPERTY_EXTRA_HEALTH_BONUS,
	MODIFIER_PROPERTY_ATTACKSPEED_BONUS_CONSTANT,
}
  return funcs
end

function modifier_crown_summoned_buff_lua:GetModifierExtraHealthBonus( params )
	local bonus_hp = self:GetAbility():GetSpecialValueFor( "hp_bonus_per_str" )
	local bonus_damage = self:GetAbility():GetSpecialValueFor( "damage_bonus_per_int" )
	local bonus_armor = self:GetAbility():GetSpecialValueFor( "armor_bonus_per_agi" )
	local model_scale =  self:GetAbility():GetSpecialValueFor( "model_scale_per_att" )
	print("this"..bonus_hp.." "..self:GetCaster().owner.crownLevel)
    --为德鲁伊小熊特别修正
    if self:GetCaster():GetUnitName()=="npc_dota_lone_druid_bear1" or self:GetCaster():GetUnitName()=="npc_dota_lone_druid_bear2" or self:GetCaster():GetUnitName()=="npc_dota_lone_druid_bear3" or self:GetCaster():GetUnitName()=="npc_dota_lone_druid_bear4" then
         local owner=self:GetCaster().owner
         local crownLevel=self:GetCaster().owner.crownLevel
         --体型
         local att_sum = owner:GetIntellect()+ owner:GetStrength()+ owner:GetAgility()        
         local scale=self:GetParent():GetModelScale()
         self:GetParent():SetModelScale(scale*(1+att_sum*0.0015))
         --攻击力
         local minDamage=self:GetCaster():GetBaseDamageMin()*(1+owner:GetIntellect() * (crownLevel*0.01+0.01) )
         local maxDamage=self:GetCaster():GetBaseDamageMax()*(1+owner:GetIntellect() * (crownLevel*0.01+0.01) )
         self:GetCaster():SetBaseDamageMin(minDamage)
         self:GetCaster():SetBaseDamageMax(maxDamage)
            --护甲
         local armor=self:GetCaster():GetPhysicalArmorBaseValue()
         local armor_bonus=owner:GetAgility() * (crownLevel *0.05+0.05)
         self:GetCaster():SetPhysicalArmorBaseValue(armor+armor_bonus)
         return owner:GetStrength() * self:GetCaster():GetMaxHealth() * crownLevel *0.01
    end

	if self:GetCaster() and self:GetCaster().owner and bonus_hp>0  then
		if  self:GetCaster().healthLock==nil then
			local owner=self:GetCaster().owner
			print("owner str"..owner:GetStrength().."bonus_hp "..bonus_hp.."result".. owner:GetStrength() * bonus_hp  * self:GetCaster():GetMaxHealth())
            --体型
            local att_sum = owner:GetIntellect()+ owner:GetStrength()+ owner:GetAgility()        
            local scale=self:GetParent():GetModelScale()
            self:GetParent():SetModelScale(scale*(1+att_sum*model_scale))
            --攻击力
            local minDamage=self:GetCaster():GetBaseDamageMin()*(1+owner:GetIntellect() * bonus_damage)
            local maxDamage=self:GetCaster():GetBaseDamageMax()*(1+owner:GetIntellect() * bonus_damage)
            self:GetCaster():SetBaseDamageMin(minDamage)
            self:GetCaster():SetBaseDamageMax(maxDamage)
            --护甲
            local armor=self:GetCaster():GetPhysicalArmorBaseValue()
            local armor_bonus=owner:GetAgility() * bonus_armor 
            self:GetCaster():SetPhysicalArmorBaseValue(armor+armor_bonus)
            --血量
 			self:GetCaster().healthLock=owner:GetStrength() * bonus_hp  * self:GetCaster():GetMaxHealth()
			return self:GetCaster().healthLock
		else 
			return self:GetCaster().healthLock
		end
	else
	    if self:GetCaster().healthLock then
		  return self:GetCaster().healthLock
	    else
          return 0
	    end
	end
end


function modifier_crown_summoned_buff_lua:GetModifierAttackSpeedBonus_Constant( params )
	return self:GetCaster():GetPhysicalArmorBaseValue()*2  --等同于两倍的攻击速度
end
