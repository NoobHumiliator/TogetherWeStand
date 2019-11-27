require("ai_core")
require("ai_shared")
require("event_queue")

function Spawn(entityKeyValues)
    if thisEntity == nil then
        return
    end

    if IsServer() == false then
        return
    end

    thisEntity.EventQueue = CEventQueue()

    thisEntity.hLightningBolt = thisEntity:FindAbilityByName("creature_mini_zeus_lightning_bolt")

    local flNow = GameRules:GetGameTime()


    thisEntity.flLightningStrikeRange = 1600
    thisEntity.flLightningStrikeAcquireRange = 1000
    thisEntity.flLightningStrikeCooldown = 3
    thisEntity.flLightningStrikeAllyCooldown = 1.2
    thisEntity.flLastLightningTime = flNow - thisEntity.flLightningStrikeCooldown

    local fInitialDelay = RandomFloat(0, 1.5) -- separating out the timing of all the ranged creeps' thinks
    thisEntity:SetContextThink("MiniZeusThink", MiniZeusThink, fInitialDelay)
end

function MiniZeusThink()
    if thisEntity == nil or thisEntity:IsNull() or thisEntity:IsAlive() == false then
        return -1
    end

    if GameRules:IsGamePaused() then
        return 0.1
    end

    local flNow = GameRules:GetGameTime()

    if (flNow - thisEntity.flLastLightningTime) > thisEntity.flLightningStrikeCooldown then

        local hEnemies = GetEnemyHeroesInRange(thisEntity, thisEntity.flLightningStrikeAcquireRange)
        if #hEnemies > 0 then
            local hTarget = GetRandomUnique(hEnemies)
            return CastLightningStrike(thisEntity, hTarget)
        end
    end

    return AttackNearestEnemy(thisEntity)
end

function CastLightningStrike(hCaster, hTarget)
    if hCaster == nil or hCaster:IsNull() then
        return -1
    end

    local hAbility = hCaster.hLightningBolt

    local flNow = GameRules:GetGameTime()

    local vBoltPosition = hTarget:GetOrigin() + Vector(0, 0, 175)

    local pszParticle = "particles/creatures/mini_zeus/mini_zeus_lightning_preview.vpcf"
    --local pszParticle = "particles/dark_moon/darkmoon_creep_warning.vpcf"
    hCaster.nPreviewFX = ParticleManager:CreateParticle(pszParticle, PATTACH_CUSTOMORIGIN, hCaster)
    ParticleManager:SetParticleControl(hCaster.nPreviewFX, 0, vBoltPosition)
    --ParticleManager:SetParticleControl( hCaster.nPreviewFX, 1, Vector( 50, 50, 50 ) )
    --ParticleManager:SetParticleControl( hCaster.nPreviewFX, 15, Vector( 252, 118, 46 ) )
    hCaster.EventQueue:AddEvent(1.5,
    function(hCaster, hAbility, vBoltPosition)
        ExecuteOrderFromTable({
            UnitIndex = hCaster:entindex(),
            OrderType = DOTA_UNIT_ORDER_CAST_POSITION,
            Position = vBoltPosition,
            AbilityIndex = hAbility:entindex(),
            Queue = false,
        })
    end, hCaster, hAbility, vBoltPosition)

    hCaster.EventQueue:AddEvent(1.75,
    function(hCaster)
        if hCaster.nPreviewFX ~= nil then
            ParticleManager:DestroyParticle(hCaster.nPreviewFX, false)
            hCaster.nPreviewFX = nil
        end
    end, hCaster)

    hCaster.flLastLightningTime = flNow

    return 0.5
end