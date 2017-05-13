require( "vip/econ")

function CHoldoutGameMode:ConfirmParticle(keys)
  local particleName=keys.particleName
	if particleName and PlayerResource:HasSelectedHero( keys.playerId ) then
		local hero = PlayerResource:GetSelectedHeroEntity( keys.playerId )
		if Econ["OnEquip_" .. particleName .. "_server"] then
       Econ["OnEquip_" .. particleName .. "_server"](hero)
    end
	end
end



function CHoldoutGameMode:CancleParticle(keys)
    local particleName=keys.particleName
	if PlayerResource:HasSelectedHero( keys.playerId ) then
		local hero = PlayerResource:GetSelectedHeroEntity( keys.playerId )
		RemoveAllParticlesOnHero(hero)
    end
end
