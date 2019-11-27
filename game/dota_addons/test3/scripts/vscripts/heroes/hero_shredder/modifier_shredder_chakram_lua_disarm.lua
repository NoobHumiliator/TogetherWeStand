modifier_shredder_chakram_lua_disarm = class({})

function modifier_shredder_chakram_lua_disarm:IsHidden()
    return false
end

function modifier_shredder_chakram_lua_disarm:IsDebuff()
    return false
end

function modifier_shredder_chakram_lua_disarm:IsPurgable()
    return false
end

function modifier_shredder_chakram_lua_disarm:GetAttributes()
    return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_shredder_chakram_lua_disarm:OnCreated(kv)
end

function modifier_shredder_chakram_lua_disarm:OnRefresh(kv)
end

function modifier_shredder_chakram_lua_disarm:OnRemoved()
end

function modifier_shredder_chakram_lua_disarm:OnDestroy()
end

--------------------------------------------------------------------------------
-- Status Effects
function modifier_shredder_chakram_lua_disarm:CheckState()
    local state = {
        [MODIFIER_STATE_DISARMED] = true,
    }

    return state
end