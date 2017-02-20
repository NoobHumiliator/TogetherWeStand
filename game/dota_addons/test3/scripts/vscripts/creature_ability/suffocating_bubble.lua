--[[
具体承受伤害的逻辑
统一放在damage filter中处理
]]

function BubbleCreate( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target= keys.target

    if target.suffocating_bubble_damage==nil or target.suffocating_bubble_damage<=0 then
    	local initDamage = ability:GetLevelSpecialValueFor("init_damage", ability:GetLevel()-1)
    	target.suffocating_bubble_damage=initDamage
    end


    if target.suffocating_bubble_take==nil or target.suffocating_bubble_take<=0 then  --气泡承受伤害
    	local takeDamage = ability:GetLevelSpecialValueFor("take_damage", ability:GetLevel()-1)
    	target.suffocating_bubble_take=takeDamage
    end

end


function BubbleDamage( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target= keys.target

    if target~=nil and target.suffocating_bubble_damage~=nil and target.suffocating_bubble_damage>0 then
    	local increaseDamage = ability:GetLevelSpecialValueFor("increase_damage", ability:GetLevel()-1)
    	local damageTable = 
        {
            victim=target,
            attacker=caster,
            damage_type=DAMAGE_TYPE_PURE,
            damage=target.suffocating_bubble_damage
        }
        ApplyDamage(damageTable)
        if target.suffocating_bubble_damage~=nil then
           target.suffocating_bubble_damage=target.suffocating_bubble_damage+increaseDamage
        end
    end
    
end


function BubbleDestroy( keys )
	local caster = keys.caster
	local ability = keys.ability
	local target= keys.target

    target.suffocating_bubble_damage=nil
end