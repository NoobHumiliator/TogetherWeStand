function PrintTable(t, indent, done)
    --print ( string.format ('PrintTable type %s', type(keys)) )
    if type(t) ~= "table" then return end

    done = done or {}
    done[t] = true
    indent = indent or 0

    local l = {}
    for k, v in pairs(t) do
        table.insert(l, k)
    end

    table.sort(l)
    for k, v in ipairs(l) do
        -- Ignore FDesc
        if v ~= 'FDesc' then
            local value = t[v]

            if type(value) == "table" and not done[value] then
                done[value] = true
                print(string.rep("\t", indent) .. tostring(v) .. ":")
                PrintTable(value, indent + 2, done)
            elseif type(value) == "userdata" and not done[value] then
                done[value] = true
                print(string.rep("\t", indent) .. tostring(v) .. ": " .. tostring(value))
                PrintTable((getmetatable(value) and getmetatable(value).__index) or getmetatable(value), indent + 2, done)
            else
                if t.FDesc and t.FDesc[v] then
                    print(string.rep("\t", indent) .. tostring(t.FDesc[v]))
                else
                    print(string.rep("\t", indent) .. tostring(v) .. ": " .. tostring(value))
                end
            end
        end
    end
end

function ListModifiers(hUnit)

    if not hUnit then
        print('Failed to find unit to  list modifiers.')
        return
    end

    print('Modifiers for ' .. hUnit:GetUnitName())

    local count = hUnit:GetModifierCount()
    for i = 0, count - 1 do
        print(hUnit:GetModifierNameByIndex(i))
    end
end

function Quadric(a, b, c)  --解一元二次方程 输出最大值
    local a2 = 2 * a
    local d = math.sqrt(b ^ 2 - 4 * a * c)
    x1 = (-b + d) / a2
    x2 = (-b - d) / a2
    if x1 > x2 then
        return x1
    else
        return x2
    end
end

function GetValidPlayerNumber()  --获取有多少已经选了英雄的玩家
    local playerNumber = 0
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
            if PlayerResource:HasSelectedHero(nPlayerID) then
                playerNumber = playerNumber + 1
            end
        end
    end
    return playerNumber
end


-- Colors
COLOR_NONE = '\x06'
COLOR_GRAY = '\x06'
COLOR_GREY = '\x06'
COLOR_GREEN = '\x0C'
COLOR_DPURPLE = '\x0D'
COLOR_SPINK = '\x0E'
COLOR_DYELLOW = '\x10'
COLOR_PINK = '\x11'
COLOR_RED = '\x12'
COLOR_LGREEN = '\x15'
COLOR_BLUE = '\x16'
COLOR_DGREEN = '\x18'
COLOR_SBLUE = '\x19'
COLOR_PURPLE = '\x1A'
COLOR_ORANGE = '\x1B'
COLOR_LRED = '\x1C'
COLOR_GOLD = '\x1D'


function string.trim(s)
    return s:match "^%s*(.-)%s*$"
end


function ReportHeroAbilities(hHero)
    if IsValidEntity(hHero) then
        for i = 1, 20 do
            local ability = hHero:GetAbilityByIndex(i - 1)
            if ability then
                print("Abilities Report: " .. hHero:GetUnitName() .. "ability[" .. i .. "] is " .. ability:GetAbilityName())
            else
                print("Abilities Report: " .. hHero:GetUnitName() .. "ability[" .. i .. "] is empty")
            end
        end
    end
end


function ListLearnedAbilities(hHero)  --输出天赋树、damage_counter以外的技能
    local result = "" --输出一个技能列表
    if IsValidEntity(hHero) then
        for i = 1, 20 do
            local ability = hHero:GetAbilityByIndex(i - 1)
            if ability and string.sub(ability:GetAbilityName(), 1, 14) ~= "special_bonus_" and ability:GetAbilityName() ~= "damage_counter" then
                result = result .. ability:GetAbilityName() .. ":" .. ability:GetLevel() .. ";"
            end
        end
    end
    return result
end



function ListSaveAbilities(hHero)  --输出天赋树、damage_counter以外的技能
    local vResult = {} --输出一个技能table
    if IsValidEntity(hHero) then
        for i = 1, 20 do
            local ability = hHero:GetAbilityByIndex(i - 1)
            if ability then
                local vAbility = {}
                vAbility.abilityName = ability:GetAbilityName()
                vAbility.abilityIndex = ability:GetAbilityIndex()
                vAbility.abilityLevel = ability:GetLevel()
                vAbility.isHidden = ability:IsHidden()
                table.insert(vResult, vAbility)
            end
        end
    end
    return vResult
end


function ListSaveModifiers(hHero)  --列出全部的BUFF
    local vResult = {} --列出全部的BUFF
    if IsValidEntity(hHero) then
        local count = hHero:GetModifierCount()  --Buff数量
        for i = 0, count - 1 do
            local vModifier = {}
            vModifier.modifierName = hHero:GetModifierNameByIndex(i)
            local modifier = hHero:FindModifierByName(vModifier.modifierName)
            vModifier.modifierStack = hHero:GetModifierStackCount(vModifier.modifierName, modifier:GetAbility())
            if modifier:GetAbility() then
                vModifier.modifierAbilityName = modifier:GetAbility():GetAbilityName()
            end
            table.insert(vResult, vModifier)
        end
    end
    --PrintTable(vResult)
    return vResult
end


function LoadModifier(ability, caster, unit, modifier, stack_count)
    if ability then
        print("d" .. ability:GetAbilityName())
        if stack_count > 0 then
            ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
            caster:SetModifierStackCount(modifier, ability, stack_count)
        else
            if not caster:HasModifier(modifier) then
                --ability:ApplyDataDrivenModifier(caster, caster, modifier, {})
                caster:AddNewModifier(caster, ability, modifier, nil)
            end
        end
    end
end

--============ Copyright (c) Valve Corporation, All rights reserved. ==========
--
--
--=============================================================================
--/////////////////////////////////////////////////////////////////////////////
-- Debug helpers
--
--  Things that are really for during development - you really should never call any of this
--  in final/real/workshop submitted code
--/////////////////////////////////////////////////////////////////////////////
-- if you want a table printed to console formatted like a table (dont we already have this somewhere?)
scripthelp_LogDeepPrintTable = "Print out a table (and subtables) to the console"
logFile = "log/log.txt"

function LogDeepSetLogFile(file)
    logFile = file
end

function LogEndLine(line)
    AppendToLogFile(logFile, line .. "\n")
end

function _LogDeepPrintMetaTable(debugMetaTable, prefix)
    _LogDeepPrintTable(debugMetaTable, prefix, false, false)
    if getmetatable(debugMetaTable) ~= nil and getmetatable(debugMetaTable).__index ~= nil then
        _LogDeepPrintMetaTable(getmetatable(debugMetaTable).__index, prefix)
    end
end

function _LogDeepPrintTable(debugInstance, prefix, isOuterScope, chaseMetaTables)
    prefix = prefix or ""
    local string_accum = ""
    if debugInstance == nil then
        LogEndLine(prefix .. "<nil>")
        return
    end
    local terminatescope = false
    local oldPrefix = ""
    if isOuterScope then  -- special case for outer call - so we dont end up iterating strings, basically
        if type(debugInstance) == "table" then
            LogEndLine(prefix .. "{")
            oldPrefix = prefix
            prefix = prefix .. "   "
            terminatescope = true
        else
            LogEndLine(prefix .. " = " .. (type(debugInstance) == "string" and ("\"" .. debugInstance .. "\"") or debugInstance))
        end
    end
    local debugOver = debugInstance

    -- First deal with metatables
    if chaseMetaTables == true then
        if getmetatable(debugOver) ~= nil and getmetatable(debugOver).__index ~= nil then
            local thisMetaTable = getmetatable(debugOver).__index
            if vlua.find(_LogDeepprint_alreadyseen, thisMetaTable) ~= nil then
                LogEndLine(string.format("%s%-32s\t= %s (table, already seen)", prefix, "metatable", tostring(thisMetaTable)))
            else
                LogEndLine(prefix .. "metatable = " .. tostring(thisMetaTable))
                LogEndLine(prefix .. "{")
                table.insert(_LogDeepprint_alreadyseen, thisMetaTable)
                _LogDeepPrintMetaTable(thisMetaTable, prefix .. "   ", false)
                LogEndLine(prefix .. "}")
            end
        end
    end

    -- Now deal with the elements themselves
    -- debugOver sometimes a string??
    for idx, data_value in pairs(debugOver) do
        if type(data_value) == "table" then
            if vlua.find(_LogDeepprint_alreadyseen, data_value) ~= nil then
                LogEndLine(string.format("%s%-32s\t= %s (table, already seen)", prefix, idx, tostring(data_value)))
            else
                local is_array = #data_value > 0
                local test = 1
                for idx2, val2 in pairs(data_value) do
                    if type(idx2) ~= "number" or idx2 ~= test then
                        is_array = false
                        break
                    end
                    test = test + 1
                end
                local valtype = type(data_value)
                if is_array == true then
                    valtype = "array table"
                end
                LogEndLine(string.format("%s%-32s\t= %s (%s)", prefix, idx, tostring(data_value), valtype))
                LogEndLine(prefix .. (is_array and "[" or "{"))
                table.insert(_LogDeepprint_alreadyseen, data_value)
                _LogDeepPrintTable(data_value, prefix .. "   ", false, true)
                LogEndLine(prefix .. (is_array and "]" or "}"))
            end
        elseif type(data_value) == "string" then
            LogEndLine(string.format("%s%-32s\t= \"%s\" (%s)", prefix, idx, data_value, type(data_value)))
        else
            LogEndLine(string.format("%s%-32s\t= %s (%s)", prefix, idx, tostring(data_value), type(data_value)))
        end
    end
    if terminatescope == true then
        LogEndLine(oldPrefix .. "}")
    end
end


function LogDeepPrintTable(debugInstance, prefix, isPublicScriptScope)
    prefix = prefix or ""
    _LogDeepprint_alreadyseen = {}
    table.insert(_LogDeepprint_alreadyseen, debugInstance)
    _LogDeepPrintTable(debugInstance, prefix, true, isPublicScriptScope)
end


--/////////////////////////////////////////////////////////////////////////////
-- Fancy new LogDeepPrint - handles instances, and avoids cycles
--
--/////////////////////////////////////////////////////////////////////////////
-- @todo: this is hideous, there must be a "right way" to do this, im dumb!
-- outside the recursion table of seen recurses so we dont cycle into our components that refer back to ourselves
_LogDeepprint_alreadyseen = {}


-- the inner recursion for the LogDeep print
function _LogDeepToString(debugInstance, prefix)
    local string_accum = ""
    if debugInstance == nil then
        return "LogDeep Print of NULL" .. "\n"
    end
    if prefix == "" then  -- special case for outer call - so we dont end up iterating strings, basically
        if type(debugInstance) == "table" or type(debugInstance) == "table" or type(debugInstance) == "UNKNOWN" or type(debugInstance) == "table" then
            string_accum = string_accum .. (type(debugInstance) == "table" and "[" or "{") .. "\n"
            prefix = "   "
        else
            return " = " .. (type(debugInstance) == "string" and ("\"" .. debugInstance .. "\"") or debugInstance) .. "\n"
        end
    end
    local debugOver = type(debugInstance) == "UNKNOWN" and getclass(debugInstance) or debugInstance
    for idx, val in pairs(debugOver) do
        local data_value = debugInstance[idx]
        if type(data_value) == "table" or type(data_value) == "table" or type(data_value) == "UNKNOWN" or type(data_value) == "table" then
            if vlua.find(_LogDeepprint_alreadyseen, data_value) ~= nil then
                string_accum = string_accum .. prefix .. idx .. " ALREADY SEEN " .. "\n"
            else
                local is_array = type(data_value) == "table"
                string_accum = string_accum .. prefix .. idx .. " = ( " .. type(data_value) .. " )" .. "\n"
                string_accum = string_accum .. prefix .. (is_array and "[" or "{") .. "\n"
                table.insert(_LogDeepprint_alreadyseen, data_value)
                string_accum = string_accum .. _LogDeepToString(data_value, prefix .. "   ")
                string_accum = string_accum .. prefix .. (is_array and "]" or "}") .. "\n"
            end
        else
            --string_accum = string_accum .. prefix .. idx .. "\t= " .. (type(data_value) == "string" and ("\"" .. data_value .. "\"") or data_value) .. "\n"
            string_accum = string_accum .. prefix .. idx .. "\t= " .. "\"" .. tostring(data_value) .. "\"" .. "\n"
        end
    end
    if prefix == "   " then
        string_accum = string_accum .. (type(debugInstance) == "table" and "]" or "}") .. "\n" -- hack for "proving" at end - this is DUMB!
    end
    return string_accum
end

scripthelp_LogDeepString = "Convert a class/array/instance/table to a string"

function LogDeepToString(debugInstance, prefix)
    prefix = prefix or ""
    _LogDeepprint_alreadyseen = {}
    table.insert(_LogDeepprint_alreadyseen, debugInstance)
    return _LogDeepToString(debugInstance, prefix)
end

scripthelp_LogDeepPrint = "Print out a class/array/instance/table to the console"

function LogDeepPrint(debugInstance, prefix)
    prefix = prefix or ""
    LogEndLine(LogDeepToString(debugInstance, prefix))
end

NHLog = function(...)
    local tv = "\n"
    local xn = 0
    local function tvlinet(xn)
        -- body
        for i = 1, xn do
            tv = tv .. "\t"
        end
    end

    local function printTab(i, v)
        -- body
        if type(v) == "table" then
            tvlinet(xn)
            xn = xn + 1
            tv = tv .. "" .. i .. ":Table{\n"
            table.foreach(v, printTab)
            tvlinet(xn)
            tv = tv .. "}\n"
            xn = xn - 1
        elseif type(v) == nil then
            tvlinet(xn)
            tv = tv .. i .. ":nil\n"
        else
            tvlinet(xn)
            tv = tv .. i .. ":" .. tostring(v) .. "\n"
        end
    end
    local function dumpParam(tab)
        for i = 1, #tab do
            if tab[i] == nil then
                tv = tv .. "nil\t"
            elseif type(tab[i]) == "table" then
                xn = xn + 1
                tv = tv .. "\ntable{\n"
                table.foreach(tab[i], printTab)
                tv = tv .. "\t}\n"
            else
                tv = tv .. tostring(tab[i]) .. "\t"
            end
        end
    end
    local x = ...
    if type(x) == "table" then
        table.foreach(x, printTab)
    else
        dumpParam({ ... })
        -- table.foreach({...},printTab)
    end
    print(tv)
end

function LevelUpAbility(unit, sAbilityName)
    print("sAbilityName " .. sAbilityName)
    local ability = unit:FindAbilityByName(sAbilityName)
    if ability ~= nil then
        local currentLevel = ability:GetLevel()
        print("currentLevel " .. currentLevel)
        local maxLevel = ability:GetMaxLevel()
        print("maxLevel " .. maxLevel)
        if currentLevel < maxLevel then
            ability:SetLevel(currentLevel + 1)
            print("LevelUpAbility " .. sAbilityName .. " Success")
        end
    end
end

function RemoveAllAbilities(hHero)
    if IsValidEntity(hHero) then
        for i = 1, 24 do
            local ability = hHero:GetAbilityByIndex(i - 1)
            if ability then
                hHero:RemoveAbility(ability:GetAbilityName())
            end
        end
    end
end

function RandomPosition(event)
    local caster = event.caster
    local target = event.target
    local range = event.range
    local min = 200
    if event.min then
        min = event.min
    end
    local vec = RandomVector(1)
    local vec2 = Vector(vec[1], vec[2], 0):Normalized() * RandomFloat(min, range)

    if event.circledynamic and event.circledynamic > 0 and caster then
        local i = 1
        if event.clockwise and caster:GetHealth() / caster:GetMaxHealth() < 0.75 and caster:GetHealth() / caster:GetMaxHealth() > 0.25 then
            i = -1
        end
        if caster.circle_array then
            caster.circle_array = caster.circle_array + i
        else
            caster.circle_array = 1
        end
        if caster.circle_array > event.circledynamic then
            caster.circle_array = 1
        end
        if caster.circle_array < 1 then
            caster.circle_array = event.circledynamic
        end
        local vecs = {}
        local offset_degree = 360 / event.circledynamic
        local offset_start = 0
        if event.degreeoffset then
            offset_start = event.degreeoffset
        end


        vec2 = Vector(range * math.cos(math.rad(offset_start + offset_degree * caster.circle_array)), range * math.sin(math.rad(offset_start + offset_degree * caster.circle_array)), 0)

    end
    target:SetAbsOrigin(caster:GetAbsOrigin() + vec2)
end

function ShallowCopy(orig)  --浅复制对象
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function ShuffledList(orig_list)  --洗牌
    local list = ShallowCopy(orig_list)
    local result = {}
    local count = #list
    for i = 1, count do
        local pick = RandomInt(1, #list)
        result[#result + 1] = list[pick]
        table.remove(list, pick)
    end
    return result
end

function PickRandom(reference_list)   --随机挑选
    if (#reference_list == 0) then
        return nil
    end
    local bucket = {}

    for k, v in pairs(reference_list) do
        bucket[k] = v
    end

    local pick_index = RandomInt(1, #bucket)
    local result = bucket[pick_index]
    return result
end


function TableCount(t)
    local n = 0
    for _ in pairs(t) do
        n = n + 1
    end
    return n
end

function TableFindKey(table, val)
    if table == nil then
        print("nil")
        return nil
    end

    for k, v in pairs(table) do
        if v == val then
            return k
        end
    end
    return nil
end

function BroadcastMessage(sMessage, fDuration)
    local centerMessage = {
        message = sMessage,
        duration = fDuration
    }
    FireGameEvent("show_center_message", centerMessage)
end

function CountdownTimer()
    nCOUNTDOWNTIMER = nCOUNTDOWNTIMER - 1
    local t = nCOUNTDOWNTIMER
    --print( t )
    local minutes = math.floor(t / 60)
    local seconds = t - (minutes * 60)
    local m10 = math.floor(minutes / 10)
    local m01 = minutes - (m10 * 10)
    local s10 = math.floor(seconds / 10)
    local s01 = seconds - (s10 * 10)
    local broadcast_gametimer =    {
        timer_minute_10 = m10,
        timer_minute_01 = m01,
        timer_second_10 = s10,
        timer_second_01 = s01,
    }
    CustomGameEventManager:Send_ServerToAllClients("countdown", broadcast_gametimer)
    if t <= 120 then
        CustomGameEventManager:Send_ServerToAllClients("time_remaining", broadcast_gametimer)
    end
end

function SetTimer(cmdName, time)
    print("Set the timer to: " .. time)
    nCOUNTDOWNTIMER = time
end

function RemoveModifierOneStack(hUnit, szModifierName, hAbility)
    if hUnit then
        local stack_count = hUnit:GetModifierStackCount(szModifierName, hAbility)
        if stack_count <= 1 then
            hUnit:RemoveModifierByName(szModifierName)
        else
            hUnit:SetModifierStackCount(szModifierName, hAbility, stack_count - 1)
        end
    end
end

function RemoveAllItems(unit)

    for i = 0, 11 do --遍历物品
        local item = unit:GetItemInSlot(i)
        if item then
            UTIL_Remove(item)
        end
    end
end

function RemoveDurableBuff(unit)
    unit:RemoveModifierByName("modifier_abaddon_borrowed_time")
    unit:RemoveModifierByName("modifier_oracle_false_promise_timer")
    unit:RemoveModifierByName("modifier_dazzle_shallow_grave")
end

function RemoveRedundantCourierAbility(caster) --移除多余的信使技能，直接删除会导致复活时闪退

    if caster:HasAbility("courier_go_to_secretshop") then
        caster:RemoveAbility("courier_go_to_secretshop")
    end
    if caster:HasAbility("courier_return_stash_items") then
        caster:RemoveAbility("courier_return_stash_items")
    end
    if caster:HasAbility("courier_take_stash_items") then
        caster:RemoveAbility("courier_take_stash_items")
    end
    if caster:HasAbility("courier_transfer_items") then
        caster:RemoveAbility("courier_transfer_items")
    end
    if caster:HasAbility("courier_go_to_sideshop2") then
        caster:RemoveAbility("courier_go_to_sideshop2")
    end

end

function AddRedundantCourierAbility(caster) --移除多余的信使技能，直接删除会导致复活时闪退
    if not caster:HasAbility("courier_go_to_secretshop") then
        caster:AddAbility("courier_go_to_secretshop")
        caster:FindAbilityByName("courier_go_to_secretshop"):SetLevel(1)
        caster:FindAbilityByName("courier_go_to_secretshop"):SetHidden(true)
    end
    if not caster:HasAbility("courier_return_stash_items") then
        caster:AddAbility("courier_return_stash_items")
        caster:FindAbilityByName("courier_return_stash_items"):SetLevel(1)
        caster:FindAbilityByName("courier_return_stash_items"):SetHidden(true)
    end
    if not caster:HasAbility("courier_take_stash_items") then
        caster:AddAbility("courier_take_stash_items")
        caster:FindAbilityByName("courier_take_stash_items"):SetLevel(1)
        caster:FindAbilityByName("courier_take_stash_items"):SetHidden(true)
    end
    if not caster:HasAbility("courier_transfer_items") then
        caster:AddAbility("courier_transfer_items")
        caster:FindAbilityByName("courier_transfer_items"):SetLevel(1)
        caster:FindAbilityByName("courier_transfer_items"):SetHidden(true)
    end
    if not caster:HasAbility("courier_go_to_sideshop2") then
        caster:AddAbility("courier_go_to_sideshop2")
        caster:FindAbilityByName("courier_go_to_sideshop2"):SetLevel(1)
        caster:FindAbilityByName("courier_go_to_sideshop2"):SetHidden(true)
    end
end

--Load ability KVs
local AbilityKV = LoadKeyValues("scripts/npc/npc_abilities.txt")

function FindTalentValue(talentName, key)
    local value_name = key or "value"
    local specialVal = AbilityKV[talentName]["AbilitySpecial"]
    for l, m in pairs(specialVal) do
        if m[value_name] then
            return m[value_name]
        end
    end
    return 0
end