function RecordSkipRound(keys)
    local caster = keys.caster
    local level = keys.level
    print("level" .. level)
    local gameMode = GameRules:GetGameModeEntity().CHoldoutGameMode
    local nextRoundNumber = gameMode._nRoundNumber + 1 --下一个关卡数

    while (gameMode.vRoundSkip[nextRoundNumber] and nextRoundNumber <= #gameMode._vRounds) do  --如果已经被跳关占用，继续向下找
        nextRoundNumber = nextRoundNumber + 1
    end
    if nextRoundNumber ~= #gameMode._vRounds then
        gameMode.vRoundSkip[nextRoundNumber] = level --找到没被占用的关，设置跳关等级
    end
end