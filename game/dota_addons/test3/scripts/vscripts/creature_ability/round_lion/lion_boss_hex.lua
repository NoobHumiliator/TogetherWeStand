LinkLuaModifier("modifier_disable_damage_lua", "abilities/modifier_disable_damage_lua", LUA_MODIFIER_MOTION_NONE)

function Hex(keys)
    -- Ability properties
    local caster = keys.caster
    local ability = keys.ability
    local ability_level = ability:GetLevel() - 1
    local sound_cast = keys.sound_cast
    local modifier_hex = keys.modifier_hex
    local hex_particle = keys.hex_particle


    local enemies = FindUnitsInRadius(caster:GetTeamNumber(), caster:GetAbsOrigin(), nil, 18000, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, FIND_ANY_ORDER, false)
    -- Play sound
    caster:EmitSound(sound_cast)
    --print("enemies"..#enemies)
    for _, enemy in pairs(enemies) do
        if enemy:IsIllusion() then
            enemy:ForceKill(true)
        else
            local hex_particle = ParticleManager:CreateParticle(hex_particle, PATTACH_CUSTOMORIGIN, enemy)
            ParticleManager:SetParticleControl(hex_particle, 0, enemy:GetAbsOrigin())
            ability:ApplyDataDrivenModifier(caster, enemy, modifier_hex, {})
        end
    end

    local runeMaxNumer = 320 * (0.5 + 0.5 * GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound.Palyer_Number) --根据玩家数量调节神符数量
    --print("runeMaxNumer"..runeMaxNumer)
    --[[    if caster:HasAbility("lion_boss_impale_circular") then  --变形期间没有尖刺
    	caster:FindAbilityByName("lion_boss_impale_circular"):StartCooldown(33)
    end
    ]]
    --五个人 3倍神符数量
    Timers:CreateTimer({
        callback = function()
            if GameRules:GetGameModeEntity().CHoldoutGameMode._currentRound ~= nil then  --如果本关结束 不再刷符
                local x = RandomInt(world_left_x, world_right_x)
                local y = RandomInt(world_left_y, world_right_y)
                vector = GetGroundPosition(Vector(x, y, 0), nil)
                local rune = CreateItem("item_rune_life_extension", nil, nil)
                CreateItemOnPositionSync(vector, rune)
                if caster.life_rune_numer == nil then  --记录一下续命符产出数量
                    caster.life_rune_numer = 1
                else
                    caster.life_rune_numer = caster.life_rune_numer + 1
                end
                if caster.life_rune_numer > runeMaxNumer then
                    caster.life_rune_numer = nil --清空数量
                    return nil
                else
                    return (28 / runeMaxNumer)  --变形持续32秒  28秒必须刷完神符
                end
            else
                return nil
            end
        end
    })
    Timers:CreateTimer({  --35秒后清理续命符
        endTime = 35,
        callback = function()
            local items = Entities:FindAllByClassname("dota_item_drop")
            --print("items"..#items)
            if not caster:IsNull() and caster:IsAlive() then
                for _, item in pairs(items) do
                    local containedItem = item:GetContainedItem()
                    if containedItem then
                        print(" containedItem:GetAbilityName()" .. containedItem:GetAbilityName())
                        if containedItem:GetAbilityName() == "item_rune_life_extension" then
                            UTIL_Remove(item)
                        end
                    end
                end
            end
        end
    })
end

function HexModelChange(keys)
    local target = keys.target
    local model_frog = keys.model_frog
    local ability = keys.ability
    -- Stores the day model to revert to it later
    if not target.hex_original_model then
        target.hex_original_model = target:GetModelName()
    end

    -- Changes the target's model to its night mode
    target:SetOriginalModel(model_frog)
    target:SetModel(model_frog)
    --target:SetModelScale(1.5)
    target:EmitSound("Hero_Lion.Hex.Target")

    local countDownParticle = ParticleManager:CreateParticle("particles/hw_fx/candy_carrying_stack.vpcf", PATTACH_OVERHEAD_FOLLOW, target)
    target.countDownParticle = countDownParticle
    target.life_time = 12
    ParticleManager:SetParticleControl(target.countDownParticle, 2, Vector(1, 2, 0))  --这里要改时间

    target:AddNewModifier(target, ability, "modifier_disable_damage_lua", {})  --禁止造成伤害
end


function Onthink(event)
    local target = event.target
    local ability = event.ability

    target.life_time = target.life_time - 1
    if target.life_time <= 0 then
        target:SetMana(0)
        target:ForceKill(true)
        return
    end
    if target.life_time < 10 and target.life_time >= 0 then
        ParticleManager:SetParticleControl(target.countDownParticle, 2, Vector(0, target.life_time, 0))
    else
        ParticleManager:SetParticleControl(target.countDownParticle, 2, Vector(math.floor(target.life_time / 10), target.life_time - math.floor(target.life_time / 10) * 10, 0))
    end
end


function LifeExtension(event)  --吃符
    local caster = event.caster

    if not caster:HasModifier("modifier_disable_damage_lua") then
        return
    end

    caster.life_time = caster.life_time + 1  -- +1s

    if caster.life_time < 10 and caster.life_time >= 0 then
        ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(0, caster.life_time, 0))
    else
        ParticleManager:SetParticleControl(caster.countDownParticle, 2, Vector(math.floor(caster.life_time / 10), caster.life_time - math.floor(caster.life_time / 10) * 10, 0))
    end
end


function HexModelRevert(keys)
    local target = keys.target

    -- Checking for errors
    if target.hex_original_model then
        target:SetModel(target.hex_original_model)
        target:SetOriginalModel(target.hex_original_model)
        target.hex_original_model = nil
    end
    ParticleManager:DestroyParticle(target.countDownParticle, true)
    ParticleManager:ReleaseParticleIndex(target.countDownParticle)

    target:RemoveModifierByName("modifier_disable_damage_lua")    --移除禁止造成伤害
end