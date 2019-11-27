require("addon_game_mode")

function Concussive_damage( keys )
        local caster = keys.caster       --获取施法者
        local target = keys.target
        local c_team = caster:GetTeam()         --获取施法者所在的队伍
        local vec = target:GetOrigin()                --获取施法者的位置，就是三维坐标
        local radius = 330

        local teams = DOTA_UNIT_TARGET_TEAM_ENEMY
        local types = DOTA_UNIT_TARGET_HERO
        local flags = DOTA_UNIT_TARGET_FLAG_NONE

        --获取范围内的单位，效率不是很高，在计时器里面注意使用
        local targets = FindUnitsInRadius(c_team, vec, nil, radius, teams, types, flags, FIND_CLOSEST, true)

        --利用Lua的循环迭代，循环遍历每一个单位组内的单位
        for i,unit in pairs(targets) do
                local damageTable = {victim=unit,    --受到伤害的单位
                        attacker=caster,          --造成伤害的单位
                        damage=(#targets)*(#targets)*50,        --伤害为区域内英雄数量的平方
                        damage_type=keys.ability:GetAbilityDamageType()}    --获取技能伤害类型，就是AbilityUnitDamageType的值
                ApplyDamage(damageTable)    --造成伤害
        end
        GameRules:SendCustomMessage(string.format( "Concussive shot %d hero，and deal %d damage", #targets,(#targets)*(#targets)*75), 0, 0)
end