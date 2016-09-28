require("abilities/ability_generic")


function IncreaseDamage(keys)

  	local caster=keys.caster
	  local ability = keys.ability



    if caster:HasModifier("modifier_light_ball_dummy_aura_bad_effect") then
        if   caster:HasModifier("modifier_night_damage_stack") then
             caster:RemoveModifierByName("modifier_night_damage_stack")
        end
    else
        if not caster:HasModifier("modifier_night_damage_stack") then

                AddModifier(caster, caster, ability, "modifier_night_damage_stack", nil)
                caster:SetModifierStackCount("modifier_night_damage_stack",ability,1)                                                                        
              else

              local stack_number = caster:GetModifierStackCount("modifier_night_damage_stack",ability)
              stack_number=stack_number+1
              caster:RemoveModifierByName("modifier_night_damage_stack")       
              AddModifier(caster, caster, ability, "modifier_night_damage_stack", nil)
              caster:SetModifierStackCount("modifier_night_damage_stack",ability,stack_number)                                            
        end
    end
end