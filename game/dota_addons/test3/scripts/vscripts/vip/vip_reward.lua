function GrantExtraLife()
	GameRules:GetGameModeEntity().CHoldoutGameMode.last_live=GameRules:GetGameModeEntity().CHoldoutGameMode.last_live+2
end