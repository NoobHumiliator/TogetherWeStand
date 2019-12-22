modifier_courier_fly = class({})

-----------------------------------------------------------------------------------------
function modifier_courier_fly:IsHidden()
    return false
end

-----------------------------------------------------------------------------------------
function modifier_courier_fly:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
function modifier_courier_fly:IsPermanent()
    return true
end


function modifier_courier_fly:CheckState()
    local state = {
        [MODIFIER_STATE_FLYING] = true,
    }
    return state
end
