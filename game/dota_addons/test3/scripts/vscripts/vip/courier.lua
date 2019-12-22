--LinkLuaModifier("modifier_courier_fly", "creature_ability/courier/modifier/modifier_courier_fly", LUA_MODIFIER_MOTION_NONE)

if Courier == nil then Courier = class({}) end


--信使模型表
Courier.vModelMap = {

    beetle_bark = "models/items/courier/courier_ti9/courier_ti9_lvl7/courier_ti9_lvl7_flying.vmdl",
    beetle_jaws = "models/courier/beetlejaws/mesh/beetlejaws_flying.vmdl",
    dark_moon = "models/courier/baby_rosh/babyroshan_flying.vmdl",
    desert_sand = "models/courier/baby_rosh/babyroshan_flying.vmdl",
    doomling = "models/courier/doom_demihero_courier/doom_demihero_courier_flying.vmdl",
    drodo = "models/courier/drodo/drodo_flying.vmdl",
    eimer="models/items/courier/mole_messenger/mole_messenger_lvl7_flying.vmdl",
    faceless="models/items/courier/faceless_rex/faceless_rex_flying.vmdl",
    fezzle="models/courier/smeevil_magic_carpet/smeevil_magic_carpet_flying.vmdl",
    gingerbread="models/courier/baby_rosh/babyroshan_winter18_flying.vmdl",
    --无特效，gourp选1号
    golden_roshan="models/courier/baby_rosh/babyroshan_flying.vmdl",
    --gourp选1号
    golden_beetlejaws="models/courier/beetlejaws/mesh/beetlejaws_flying.vmdl",
    --gourp选1号
    golden_doomling="models/courier/doom_demihero_courier/doom_demihero_courier_flying.vmdl",
    --无特效
    golden_greevil="models/courier/greevil/gold_greevil_flying.vmdl",
    --gourp选1号
    golden_huntling="models/courier/huntling/huntling_flying.vmdl",
    golden_krobeling="models/items/courier/krobeling_gold/krobeling_gold_flying.vmdl",
    --gourp选1号
    golden_venoling="models/courier/venoling/venoling_flying.vmdl",
    hakobi="models/items/courier/shibe_dog_cat/shibe_dog_cat_flying.vmdl",
    huntling="models/courier/huntling/huntling_flying.vmdl",
    --group选2号 无特效
    ice_roshan="models/courier/baby_rosh/babyroshan_elemental_flying.vmdl",
    krobeling="models/items/courier/krobeling/krobeling_flying.vmdl",
    --group选1号 无特效
    lava_roshan="models/courier/baby_rosh/babyroshan_elemental_flying.vmdl",
    lockjaw="models/courier/lockjaw/lockjaw_flying.vmdl",
    murrissey="models/courier/turtle_rider/turtle_rider_flying.vmdl",
    nian="models/items/courier/nian_courier/nian_courier_flying.vmdl",
    onibi="models/items/courier/onibi_lvl_21/onibi_lvl_21_flying.vmdl",
    osky="models/courier/otter_dragon/otter_dragon_flying.vmdl",
    pholi="models/items/courier/pangolier_squire/pangolier_squire_flying.vmdl",
    --gourp选2号
    platinum_roshan="models/courier/baby_rosh/babyroshan_flying.vmdl",
    --无特效
    stumpy="models/courier/stump/stump_flying.vmdl",
    trapjaw="models/courier/trapjaw/trapjaw_flying.vmdl",
    --无特效
    mountain_yak="models/courier/yak/yak_wings.vmdl",
    venoling="models/courier/venoling/venoling_flying.vmdl",
    --无特效
    war_dog="models/courier/juggernaut_dog/juggernaut_dog_wings.vmdl",
    --gourp选5号
    jade_roshan="models/courier/baby_rosh/babyroshan_flying.vmdl"
}

--信使特效表

Courier.vParticleMap = {

    beetle_bark = "particles/econ/courier/courier_ti9/courier_ti9_lvl7_base.vpcf",
    beetle_jaws = "particles/econ/courier/courier_beetlejaw/courier_beetlejaw_ambient.vpcf",
    dark_moon = "particles/econ/courier/courier_roshan_darkmoon/courier_roshan_darkmoon_flying.vpcf",
    desert_sand = "particles/econ/courier/courier_roshan_desert_sands/baby_roshan_desert_sands_ambient_flying_loadout.vpcf",
    doomling = "particles/econ/courier/courier_doomling/courier_doomling_ambient.vpcf",
    drodo = "particles/econ/courier/courier_drodo/courier_drodo_ambient.vpcf",
    eimer="particles/econ/courier/courier_mole_messenger_ti8/mole_jadedrill_ambient.vpcf",
    faceless="particles/econ/courier/courier_faceless_rex/cour_rex_flying.vpcf",
    fezzle="particles/econ/courier/courier_smeevil_flying_carpet/courier_smeevil_flying_carpet_ambient.vpcf",
    gingerbread="particles/econ/courier/courier_babyroshan_winter18/courier_babyroshan_winter18_ambient.vpcf",
    golden_beetlejaws="particles/econ/courier/courier_beetlejaw_gold/courier_beetlejaw_gold_ambient.vpcf",
    golden_doomling="particles/econ/courier/courier_golden_doomling/courier_golden_doomling_ambient.vpcf",
    golden_huntling="particles/econ/courier/courier_huntling_gold/courier_huntling_gold_ambient_flying.vpcf",
    golden_krobeling="particles/econ/courier/courier_krobeling_gold/courier_krobeling_gold_ambient.vpcf",
    golden_venoling="particles/econ/courier/courier_venoling_gold/courier_venoling_ambient_gold.vpcf",
    hakobi="particles/econ/courier/courier_shibe/courier_shibe_ambient_flying.vpcf",
    huntling="particles/econ/courier/courier_huntling/courier_huntling_ambient_flying.vpcf",
    krobeling="particles/econ/courier/courier_krobeling/courier_krobeling_ambient_hair.vpcf",
    lockjaw="particles/econ/courier/courier_lockjaw/courier_lockjaw_ambient.vpcf",
    murrissey="particles/econ/courier/courier_murrissey_the_smeevil/courier_murrissey_the_smeevil_fr.vpcf",
    nian="particles/econ/courier/courier_nian/courier_nian_ambient.vpcf",
    onibi="particles/econ/courier/courier_onibi/courier_onibi_black_lvl21_ambient.vpcf",
    osky="particles/econ/courier/courier_otter_dragon/courier_otter_dragon_ambient.vpcf",
    pholi="particles/econ/courier/courier_squire/courier_squire_ambient_flying.vpcf",
    platinum_roshan="particles/econ/courier/courier_platinum_roshan/platinum_roshan_ambient.vpcf",
    trapjaw="particles/econ/courier/courier_trapjaw/courier_trapjaw_ambient.vpcf",
    venoling="particles/econ/courier/courier_venoling/courier_venoling_ambient.vpcf",
    war_dog="models/courier/juggernaut_dog/juggernaut_dog_wings.vmdl"
}

Courier.vSkinMap = {
   golden_roshan="1",
   golden_beetlejaws="1",
   golden_doomling="1",
   golden_huntling="1",
   golden_venoling="1",
   ice_roshan="2",
   lava_roshan="1",
   platinum_roshan="2",
   jade_roshan="5"
}


--7.23 为玩家创建信使
function Courier:CreateCourierForPlayers()
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS - 1 do
        if PlayerResource:GetTeam(nPlayerID) == DOTA_TEAM_GOODGUYS then
            if PlayerResource:HasSelectedHero(nPlayerID) then
                local hHero = PlayerResource:GetSelectedHeroEntity(nPlayerID)
                if hHero  then     
                    local hCourier = CreateUnitByName('npc_dota_courier', hHero:GetOrigin(), true, hHero, hHero, hHero:GetTeam())
                    hCourier:SetOwner(hHero)
                    hCourier:SetControllableByPlayer(nPlayerID, true)
                    hCourier:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
                    hCourier:SetOriginalModel('models/props_gameplay/donkey_wings.vmdl')
                    hCourier:FindAbilityByName('courier_burst'):SetLevel(1)
                    hCourier:FindAbilityByName('courier_shield'):SetLevel(1)
                    hCourier.nCourierOwnerId =  nPlayerID
                    --加buff也无法飞高 ?
                    --hCourier:AddNewModifier(hCourier, nil, 'modifier_courier_fly', {})
                    hHero.hCourier = hCourier
                end
            end
        end
    end
end



function CHoldoutGameMode:ConfirmCourier(keys)
    local courierCode = keys.courierCode
    if courierCode and PlayerResource:HasSelectedHero(keys.playerId) then
        local hHero = PlayerResource:GetSelectedHeroEntity(keys.playerId)
        if hHero and hHero.hCourier then
            --摧毁之前的特效
            if hHero.hCourier.nCourierParticleIndex~=nil then
               ParticleManager:DestroyParticle(hHero.hCourier.nCourierParticleIndex, true)
               ParticleManager:ReleaseParticleIndex(hHero.hCourier.nCourierParticleIndex)
               hHero.hCourier.nCourierParticleIndex=nil
            end

            if Courier.vModelMap[courierCode] then
              hHero.hCourier:SetOriginalModel(Courier.vModelMap[courierCode])
              hHero.hCourier:SetModel(Courier.vModelMap[courierCode])
            end
            if Courier.vParticleMap[courierCode] then
               local nParticleIndex = ParticleManager:CreateParticle(Courier.vParticleMap[courierCode], PATTACH_ABSORIGIN_FOLLOW, hHero.hCourier)
               ParticleManager:SetParticleControlEnt(nParticleIndex, 0, hHero.hCourier, PATTACH_ABSORIGIN_FOLLOW, "follow_origin", hHero.hCourier:GetAbsOrigin(), true)
               hHero.hCourier.nCourierParticleIndex= nParticleIndex
            end
            if Courier.vSkinMap[courierCode] then
               hHero.hCourier:SetMaterialGroup(Courier.vSkinMap[courierCode])
            else
               hHero.hCourier:SetMaterialGroup("0")
            end
        end
    end
end