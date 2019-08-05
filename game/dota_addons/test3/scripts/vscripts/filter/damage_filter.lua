--damageTable.damagetype_const
--1 physical
--2 magical
--4 pure
sp_exempt_table = {}
sp_exempt_table["necrolyte_reapers_scythe_lua"] = true
sp_exempt_table["necrolyte_heartstopper_aura_lua"] = true
sp_exempt_table["necrolyte_heartstopper_aura_level_2_lua"] = true
sp_exempt_table["necrolyte_heartstopper_aura_level_3_lua"] = true
sp_exempt_table["huskar_life_break"] = true
sp_exempt_table["frostivus2018_huskar_life_break"] = true
sp_exempt_table["death_prophet_spirit_siphon"] = true
sp_exempt_table["elder_titan_earth_splitter"] = true
sp_exempt_table["winter_wyvern_arctic_burn"] = true
sp_exempt_table["doom_bringer_infernal_blade"] = true
sp_exempt_table["phoenix_sun_ray"] = true
sp_exempt_table["abyssal_underlord_firestorm"] = true
sp_exempt_table["zuus_static_field"] = true
sp_exempt_table["zuus_static_field_lua"] = true
sp_exempt_table["spectre_dispersion"] = true
sp_exempt_table["spectre_dispersion_lua"] = true
sp_exempt_table["item_blade_mail"] = true
sp_exempt_table["witch_doctor_maledict"] = true
sp_exempt_table["undying_flesh_golem"] = true
sp_exempt_table["viper_corrosive_skin"] = true
sp_exempt_table["nyx_assassin_spiked_carapace"] = true

re_table = {} --反伤类技能  折射单独处理
re_table["bristleback_quill_spray"] = true
re_table["bristleback_bristleback"] = true
re_table["centaur_return"] = true
re_table["centaur_return_lua"] = true
re_table["viper_corrosive_skin"] = true
re_table["item_blade_mail"] = true
re_table["axe_counter_helix"] = true
re_table["nyx_assassin_spiked_carapace"] = true

-- DamageFilter不应滥用  只处理两种问题 1 是否造成伤害 2 伤害来源是具体哪个技能 其余问题都不应该从这里处理
function CHoldoutGameMode:DamageFilter(damageTable)

    --DeepPrint( damageTable )
    if damageTable.entindex_attacker_const == nil then
        return true
    end

    local attacker = EntIndexToHScript(damageTable.entindex_attacker_const)
    local victim = EntIndexToHScript(damageTable.entindex_victim_const)
    local ability = nil
    if damageTable.entindex_inflictor_const ~= nil then
        ability = EntIndexToHScript(damageTable.entindex_inflictor_const)
    end
    local damage_type = damageTable.damagetype_const

    --玩家方造成伤害
    if attacker:GetTeam() == DOTA_TEAM_GOODGUYS then
        local playerid = attacker:GetPlayerOwnerID()
        if attacker:IsRealHero() then
            if ability ~= nil then --有明确来源技能
                if attacker.sp ~= nil and damage_type == DAMAGE_TYPE_MAGICAL and not sp_exempt_table[ability:GetAbilityName()] then
                    if ability:IsToggle() or ability:IsPassive() then
                        damageTable.damage = damageTable.damage * (1 + attacker.sp * 0.3 * attacker:GetIntellect() / 100)
                    else
                        damageTable.damage = damageTable.damage * (1 + attacker.sp * attacker:GetIntellect() / 100)
                    end
                elseif ability.GetAbilityName and re_table[ability:GetAbilityName()] then
                    if attacker.pysical_return ~= nil and damage_type == DAMAGE_TYPE_PHYSICAL then --物理类反伤处理技能
                        damageTable.damage = damageTable.damage * (1 + attacker.pysical_return * attacker:GetStrength() / 100)
                    end
                    if attacker.magical_return ~= nil and damage_type == DAMAGE_TYPE_MAGICAL then --魔法类反伤处理技能
                        damageTable.damage = damageTable.damage * (1 + attacker.magical_return * attacker:GetStrength() / 100)
                    end
                    if attacker.pure_return ~= nil and damage_type == DAMAGE_TYPE_PURE then --神圣类反伤处理技能
                        damageTable.damage = damageTable.damage * (1 + attacker.pure_return * attacker:GetStrength() / 100)
                    end
                end
            else
                if attacker.sp ~= nil and damage_type == DAMAGE_TYPE_MAGICAL then --无明确来源技能
                    damageTable.damage = damageTable.damage * (1 + attacker.sp * attacker:GetIntellect() / 100)
                end
            end
        end

        if victim:HasModifier("modifier_refraction_affect") then  --如果有折光，移除一层此伤害不起作用
            local refractionAbility = victim:FindAbilityByName("ta_refraction_datadriven")
            RemoveModifierOneStack(victim, "modifier_refraction_affect", refractionAbility)
            return false
        elseif victim:HasModifier("modifier_tinker_boss_invulnerable") then  --如果有TK Boss的活性护甲
            if ability == nil or ability.GetAbilityName == nil or ability:GetAbilityName() ~= "creature_techies_suicide" then  --只有炸弹人自爆能造成伤害
                return false
            end
        end
        -- 统计伤害
        if self._currentRound and playerid and playerid ~= -1 then
            self._currentRound._vPlayerStats[playerid].nTotalDamage = self._currentRound._vPlayerStats[playerid].nTotalDamage + damageTable.damage
        end

    elseif attacker:GetTeam() == DOTA_TEAM_BADGUYS then

        if ability ~= nil and ability.GetAbilityName ~= nil then
            local gameMode = GameRules:GetGameModeEntity().CHoldoutGameMode
            local round = gameMode._currentRound

            if round ~= nil then
                if round._alias == "tidehunter" then
                    --处理窒息气泡 原始伤害
                    if victim:HasModifier("modifier_suffocating_bubble") then
                        --如果技能为潮汐的两个伤害技能
                        if (ability:GetAbilityName() == "boss_current_storm" or ability:GetAbilityName() == "boss_greate_gush") and victim.suffocating_bubble_take ~= nil and victim.suffocating_bubble_take > 0 then
                            victim.suffocating_bubble_take = victim.suffocating_bubble_take - damageTable.damage
                            if victim.suffocating_bubble_take < 100 then
                                victim:RemoveModifierByName("modifier_suffocating_bubble")
                                victim.suffocating_bubble_take = nil
                            end
                            return false
                        end
                    end
                elseif round._alias == "bloodseeker" and round.achievement_flag == true then
                    --血魔关 血之祭祀
                    if ability:GetAbilityName() == "bloodseeker_blood_bath_holdout" then
                        if victim and victim:IsRealHero() then
                            Notifications:BottomToAll({ hero = victim:GetUnitName(), duration = 4 })
                            Notifications:BottomToAll({ text = "#round4_acheivement_fail_note", duration = 4, style = { color = "Orange" }, continue = true })
                            QuestSystem:RefreshAchQuest("Achievement", 0, 1)
                            round.achievement_flag = false
                        end
                    end
                elseif round._alias == "satyr" and round.achievement_flag == true then
                    --萨特关 尖刺
                    if round._alias == "satyr" and ability:GetAbilityName() == "creature_aoe_spikes" then
                        if victim and victim:IsRealHero() then
                            Notifications:BottomToAll({ hero = victim:GetUnitName(), duration = 4 })
                            Notifications:BottomToAll({ text = "#round5_acheivement_fail_note", duration = 4, style = { color = "Orange" }, continue = true })
                            QuestSystem:RefreshAchQuest("Achievement", 0, 1)
                            round.achievement_flag = false
                        end
                    end
                elseif round._alias == "rubick" then
                    if attacker:GetUnitName() == "npc_dota_boss_rubick" and victim == attacker then
                        damageTable.damage = math.min(damageTable.damage, attacker:GetMaxHealth() * 0.01)
                    end
                end
            end
        end
    end

    return true
end