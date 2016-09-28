modifier_environment_blind_lua = class({})


function modifier_environment_blind_lua:GetAttributes()
	return 1
end


function modifier_environment_blind_lua:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_DAY_VISION,
        MODIFIER_PROPERTY_BONUS_NIGHT_VISION
	}
	return funcs
end


function modifier_environment_blind_lua:IsDebuff()
	return true;
end

--------------------------------------------------------------------------------
function modifier_environment_blind_lua:GetBonusDayVision()
	return -20000;
end
--------------------------------------------------------------------------------
function modifier_environment_blind_lua:GetBonusNightVision()
	return -20000;
end
---------------------------------------------------------------------------------
function modifier_environment_blind_lua:GetTexture()
	return "night_stalker_darkness"
end
