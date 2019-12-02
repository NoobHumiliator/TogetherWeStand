function CHoldoutGameMode:OrderFilter(orderTable)
    
    if orderTable.units["0"] == nil then
        return true
    end

    local caster = EntIndexToHScript(orderTable.units["0"])

    if caster:GetUnitName() == "npc_dota_courier" then --如果是信使

        --只允许拥有者控制信使
        if caster.nCourierOwnerId and caster.nCourierOwnerId ~= orderTable.issuer_player_id_const then
            return false
        end

        if orderTable.order_type == DOTA_UNIT_ORDER_PICKUP_ITEM then  --有人控制信使捡东西

            caster.nControlledPickPlayerId = orderTable.issuer_player_id_const  --记录下谁用信使捡东西

        elseif orderTable.order_type == DOTA_UNIT_ORDER_CAST_POSITION and orderTable.entindex_ability then

            local ability = EntIndexToHScript(orderTable.entindex_ability)
            if ability.GetAbilityName and ability:GetAbilityName() == "courier_hook_datadriven" then --有人使用信使抓钩
                caster.nControlledPickPlayerId = orderTable.issuer_player_id_const  --记录下谁用信使抓钩
            end

        elseif not (orderTable.entindex_ability and orderTable.entindex_ability > 1) then --如果有人控制信使施法以外的操作

            if caster.bSellInterrupted == nil then
                caster.bSellInterrupted = true
            end

        end

    end

    if orderTable.entindex_ability ~= 0
    and orderTable.entindex_ability ~= -1
    and orderTable.order_type ~= DOTA_UNIT_ORDER_TRAIN_ABILITY
    and caster.GetIntellect then  --order_type=11 为技能升级指令
        local ability = EntIndexToHScript(orderTable.entindex_ability)

        if ability ~= nil and ability.GetAbilityName ~= nil then
            -- if ability:GetAbilityName() ~= "storm_spirit_ball_lightning"
            -- and ability:GetAbilityName() ~= "ogre_magi_unrefined_fireblast"
            -- and ability.IsInAbilityPhase and caster.manaCostIns ~= nil
            -- and not ability:IsInAbilityPhase()
            -- and not ability:IsChanneling() then  -- 有法强
            --     local current_mana = caster:GetMana()
            --     local mana_cost = ability:GetManaCost(-1) --获取技能耗蓝
            --     --print("caster.manaCostIns"..caster.manaCostIns)
            --     caster:ReduceMana(mana_cost * (caster.manaCostIns * caster:GetIntellect() / 100))
            --     if caster:GetMana() < mana_cost then  --如果扣完蓝不够了
            --         Timers:CreateTimer({
            --             endTime = 0.0001, --再把蓝退回回去
            --             callback = function()
            --                 caster:SetMana(current_mana)
            --             end
            --         })
            --     end
            -- end

            -- 风暴双雄
            if ability:GetAbilityName() == "arc_warden_tempest_double" then

                local units = FindUnitsInRadius(DOTA_TEAM_GOODGUYS, Vector(0, 0, 0), nil, -1, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false)
                for _, unit in pairs(units) do
                    print(unit:GetUnitName())
                    print(unit:IsTempestDouble())
                    if unit:IsTempestDouble() and unit:GetPlayerOwnerID() == caster:GetPlayerOwnerID() then --移除控制者的风暴双雄
                        unit:ForceKill(true)  --移除掉原来的双雄
                    end
                end
                
            end

        end
    end
    return true
end