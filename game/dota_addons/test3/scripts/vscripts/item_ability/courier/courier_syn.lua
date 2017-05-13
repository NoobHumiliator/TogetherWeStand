
function SetCourierOwner( keys )
	local caster = keys.caster
    local target = keys.target
    local playerId=caster:GetOwner():GetPlayerID()
    
    if target.synPlayerId==nil then  --记录其专属技能ID
       target.synPlayerId=playerId
    end

end
