modifier_intellect_reduction = class({})

-----------------------------------------------------------------------------------------
function modifier_intellect_reduction:IsHidden()
    return false
end

-----------------------------------------------------------------------------------------
function modifier_intellect_reduction:IsPurgable()
    return false
end

--------------------------------------------------------------------------------
function modifier_intellect_reduction:IsPermanent()
    return true
end
----------------------------------------------------------------------------------------
function modifier_intellect_reduction:IsDebuff()
    return true
end
-----------------------------------------------------------------------------------------
function modifier_intellect_reduction:GetTexture()
    return "dilation"
end

-----------------------------------------------------------------------------------------
function modifier_intellect_reduction:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_STATS_INTELLECT_BONUS
    }
    return funcs
end
----------------------------------------
function modifier_intellect_reduction:GetModifierBonusStats_Intellect(params)
    if IsServer() then
        return -(self:GetParent():GetIntellect() / 2)
    end
end