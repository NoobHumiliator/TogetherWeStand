function OpenTreasureBox1(keys)
    local caster = keys.caster
    local map_difficulty = GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty

    if map_difficulty == nil or map_difficulty >= 3 then
        keys.ability:SetCurrentCharges(2)
        Notifications:Bottom(caster:GetPlayerID(), { text = "#treasure_box_disabled", duration = 2, style = { color = "Red" } })
        return
    end

    local nothing_chance = 0.1

    local num = RandomFloat(0, 1)

    local nothing = true
    local precious = false

    local playername = PlayerResource:GetPlayerName(caster:GetPlayerID())
    local hero_name = PlayerResource:GetSelectedHeroName(caster:GetPlayerID())

    if nothing then
        Notifications:TopToAll({ hero = hero_name, duration = 2 })
        Notifications:TopToAll({ text = playername .. " ", duration = 2, continue = true })
        Notifications:TopToAll({ text = "#treasure_box_1_nothing_inside", duration = 2, style = { color = "Orange" }, continue = true })
        EmitSoundOn("soundboard.greevil_laughs", PlayerResource:GetPlayer(caster:GetPlayerID()))
        return
    elseif precious then
        AddItemByName(caster, "item_extra_slot_9")
        Notifications:TopToAll({ hero = hero_name, duration = 4 })
        Notifications:TopToAll({ text = playername .. " ", duration = 4, continue = true })
        Notifications:TopToAll({ text = "#treasure_box_1_precious", duration = 4, style = { color = "Red" }, continue = true })
        Notifications:TopToAll({ item = "item_extra_slot_9", duration = 4 })
        EmitGlobalSound("announcer_killing_spree_announcer_kill_holy_01")
    else
        EmitSoundOn("powerup_04", PlayerResource:GetPlayer(caster:GetPlayerID()))
    end
    local particle = ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)

end

function OpenTreasureBox2(keys)
    local caster = keys.caster
    local map_difficulty = GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty

    if map_difficulty == nil or map_difficulty >= 3 then
        keys.ability:SetCurrentCharges(2)
        Notifications:Bottom(caster:GetPlayerID(), { text = "#treasure_box_disabled", duration = 2, style = { color = "Red" } })
        return
    end

    local nothing_chance = 0.05

    local nothing = false
    local precious = true

    local playername = PlayerResource:GetPlayerName(caster:GetPlayerID())
    local hero_name = PlayerResource:GetSelectedHeroName(caster:GetPlayerID())

    if nothing then
        Notifications:TopToAll({ hero = hero_name, duration = 2 })
        Notifications:TopToAll({ text = playername .. " ", duration = 2, continue = true })
        Notifications:TopToAll({ text = "#treasure_box_2_nothing_inside", duration = 2, style = { color = "Orange" }, continue = true })
        EmitSoundOn("soundboard.greevil_laughs", PlayerResource:GetPlayer(caster:GetPlayerID()))
        EmitGlobalSound("soundboard.greevil_laughs")
        return
    elseif precious then
        AddItemByName(caster, "item_greater_clarity")
        Notifications:TopToAll({ hero = hero_name, duration = 4 })
        Notifications:TopToAll({ text = playername .. " ", duration = 4, continue = true })
        Notifications:TopToAll({ text = "#treasure_box_2_precious", duration = 4, style = { color = "Red" }, continue = true })
        Notifications:TopToAll({ item = "item_butterfly_3", duration = 4 })
        EmitGlobalSound("announcer_killing_spree_announcer_kill_holy_01")
    else
        EmitSoundOn("powerup_04", PlayerResource:GetPlayer(caster:GetPlayerID()))
    end
    local particle = ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)

end

function OpenTreasureBox3(keys)
    local caster = keys.caster
    local map_difficulty = GameRules:GetGameModeEntity().CHoldoutGameMode.map_difficulty

    if map_difficulty == nil or map_difficulty >= 3 then
        keys.ability:SetCurrentCharges(2)
        Notifications:Bottom(caster:GetPlayerID(), { text = "#treasure_box_disabled", duration = 2, style = { color = "Red" } })
        return
    end

    local nothing_chance = 0.05

    local nothing = false
    local precious = true

    local playername = PlayerResource:GetPlayerName(caster:GetPlayerID())
    local hero_name = PlayerResource:GetSelectedHeroName(caster:GetPlayerID())

    if nothing then
        Notifications:TopToAll({ hero = hero_name, duration = 2 })
        Notifications:TopToAll({ text = playername .. " ", duration = 2, continue = true })
        Notifications:TopToAll({ text = "#treasure_box_3_nothing_inside", duration = 2, style = { color = "Orange" }, continue = true })
        EmitSoundOn("soundboard.greevil_laughs", PlayerResource:GetPlayer(caster:GetPlayerID()))
        return
    elseif precious then
        AddItemByName(caster, "item_extra_slot_9")
        Notifications:TopToAll({ hero = hero_name, duration = 4 })
        Notifications:TopToAll({ text = playername .. " ", duration = 4, continue = true })
        Notifications:TopToAll({ text = "#treasure_box_3_precious", duration = 4, style = { color = "Red" }, continue = true })
        Notifications:TopToAll({ item = "item_extra_slot_9", duration = 4 })
        EmitGlobalSound("announcer_killing_spree_announcer_kill_holy_01")
    else
        EmitSoundOn("powerup_04", PlayerResource:GetPlayer(caster:GetPlayerID()))
    end
    local particle = ParticleManager:CreateParticle("particles/neutral_fx/roshan_spawn.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(particle)

end