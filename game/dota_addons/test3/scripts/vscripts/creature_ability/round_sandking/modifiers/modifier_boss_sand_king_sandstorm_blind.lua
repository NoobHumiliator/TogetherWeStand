modifier_boss_sand_king_sandstorm_blind = class({})

-----------------------------------------------------------------------------------------

function modifier_boss_sand_king_sandstorm_blind:CheckState()
	local state =
	{
		[MODIFIER_STATE_BLIND] = true,
	}
	return state
end

