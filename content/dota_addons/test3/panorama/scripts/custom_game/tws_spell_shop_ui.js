"use strict";

var config = {
	"cmHeroesGroup": "file://{resources}/layout/custom_game/tws_heroes_group.xml",
	"radiobutton": "file://{resources}/layout/custom_game/tws_radiobutton.xml",
	"cmSelectionPlayer": "file://{resources}/layout/custom_game/tws_hero_ability_list.xml",
	"heroAbilityList": "file://{resources}/layout/custom_game/tws_hero_ability_list.xml",
	"playerAbilityList": "file://{resources}/layout/custom_game/tws_player_ability_list.xml",
	"adPlayerLeft": "file://{resources}/layout/custom_game/hero_selection_ad_player_left.xml",
	"adPlayerRight": "file://{resources}/layout/custom_game/hero_selection_ad_player_right.xml",
};

var unsellableAbility = {
	"shredder_chakram_lua": true,
	"shredder_chakram_2_lua": true,
	"witch_doctor_death_ward": true,
	"meepo_divided_we_stand": true,
	"broodmother_spin_web": true,
	"treant_eyes_in_the_forest": true,
	"batrider_sticky_napalm": true
};

//卖技能的面板中不显示这些技能
var hideAbility = {
	"damage_counter": true,
	"attribute_bonus": true,
	"attribute_bonus_lua": true,
	"keeper_of_the_light_illuminate_end": true,
	"keeper_of_the_light_spirit_form_illuminate": true,
	"morphling_morph_replicate": true,
	"shredder_return_chakram": true,
	"shredder_return_chakram_2": true,
	"shredder_return_chakram_lua": true,
	"shredder_return_chakram_2_lua": true,
	"elder_titan_return_spirit": true,
	"phoenix_icarus_dive_stop": true,
	"phoenix_sun_ray_stop": true,
	"phoenix_launch_fire_spirit": true,
	"abyssal_underlord_cancel_dark_rift": true,
	"alchemist_unstable_concoction_throw": true,
	"naga_siren_song_of_the_siren_cancel": true,
	"rubick_telekinesis_land": true,
	"bane_nightmare_end": true,
	"ancient_apparition_ice_blast_release": true,
	"lone_druid_true_form_druid": true,
	"nyx_assassn_unburrow": true,
	"morphling_morph": true,
	"nyx_assassin_unburrow": true,
	"pangolier_gyroshell_stop": true,
	"tiny_toss_tree": true,
	"generic_hidden": true,
	"wisp_tether_break": true,
	"wisp_spirits_in": true,
	"wisp_spirits_out": true,
	//7.23多了这个技能 原因不详
	"ability_capture": true,
};

var noReturnAbility = {    //不退回升级点数的技能
	"troll_warlord_whirling_axes_ranged": true,
	"troll_warlord_whirling_axes_melee": true,
	"lone_druid_savage_roar_bear": true,
	"phoenix_sun_ray_toggle_move": true,
	"morphling_hybrid": true,
	"morphling_morph": true,
	"morphling_morph_agi": true
}

var maxAbilitySlotNo = 6;  //最大的技能个数

//买技能锁，买技能后加锁，禁止操作 等待后台回传结果后解锁
var buySpellLocking = false;

var freeToSellAbility = false;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


var Titles_HeroesGroups = [$.Localize("#str"), $.Localize("#agi"), $.Localize("#int")];

var Text_StateAction = ["CHOOSE", "BAN", "PICK"];

var CurrentHero = ["", "", "", "", "", "", "", "", "", ""]

var previousHeroRadio = null; //暂存玩家点选的英雄按钮

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

function SetPanelText(parentPanel, childPanelId, text) {
	if (!parentPanel) {
		return;
	}

	var childPanel = parentPanel.FindChildInLayoutFile(childPanelId);
	if (!childPanel) {
		return;
	}

	childPanel.text = text;
}

function Update_Heroes_Table() {
	var container = $("#heroesTableStrAgi");
	var container_int = $("#heroesTableInt");

	//$.Msg(container);
	for (var row = 1; row <= 2; row++) {
		_cm_Heroes_UpdateRow(container, row);
	}
	_cm_Heroes_UpdateRow_int(container_int);
}

function First() {
	var container = $("#heroesTableStrAgi");
	var container_int = $("#heroesTableInt");
	//$.Msg(container);
}

function _cm_Heroes_UpdateRow(container, row) {
	var parentPanelId = "_heroes_row_" + row;
	//var parentPanel = null;
	var parentPanel = container.FindChild(parentPanelId);
	if (!parentPanel) {
		parentPanel = $.CreatePanel("Panel", container, parentPanelId);    //创建英雄组的panel
		parentPanel.BLoadLayout(config.cmHeroesGroup, false, false);       //英雄组的panel布局
		parentPanel.SetHasClass("cmHeroesRow", true);
	}

	var className = "cmHeroesGroupTitle_" + row;
	var groupNamePanel = parentPanel.FindChildInLayoutFile("GroupName");
	// SetPanelText( parentPanel, "GroupName", Titles_HeroesGroups[ row - 1 ] );
	groupNamePanel.text = Titles_HeroesGroups[row - 1];              //设置group name
	groupNamePanel.SetHasClass(className, true);                     //设置class

	var groupTable = parentPanel.FindChildInLayoutFile("GroupTable");

	for (var i = 1; i <= 2; i++) {
		var groupName = ((row - 1) * 2) + i;
		var groupKV = CustomNetTables.GetTableValue("heroes", groupName);

		var groupPanelId = "_heroes_group_" + groupName;
		var groupPanel = groupTable.FindChild(groupPanelId);
		if (!groupPanel) {
			groupPanel = $.CreatePanel("Panel", groupTable, groupPanelId);
			groupPanel.SetHasClass("cm_heroes_group", true);
		}

		_cm_Heroes_UpdateGroup(groupKV, groupPanel, groupName);
	}
}

function _cm_Heroes_UpdateRow_int(container) {
	var parentPanelId = "_heroes_row_3";
	var parentPanel = container.FindChild(parentPanelId);
	if (!parentPanel) {
		parentPanel = $.CreatePanel("Panel", container, parentPanelId);    //创建英雄组的panel
		parentPanel.BLoadLayout(config.cmHeroesGroup, false, false);       //英雄组的panel布局
		parentPanel.SetHasClass("cmHeroesRow", true);
	}

	var className = "cmHeroesGroupTitle_3";
	var groupNamePanel = parentPanel.FindChildInLayoutFile("GroupName");
	// SetPanelText( parentPanel, "GroupName", Titles_HeroesGroups[ row - 1 ] );
	groupNamePanel.text = Titles_HeroesGroups[2];              //设置group name
	groupNamePanel.SetHasClass(className, true);             //设置class

	var groupTable = parentPanel.FindChildInLayoutFile("GroupTable");

	for (var i = 1; i <= 2; i++) {
		var groupName = 4 + i;
		var groupKV = CustomNetTables.GetTableValue("heroes", groupName);

		var groupPanelId = "_heroes_group_" + groupName;
		var groupPanel = groupTable.FindChild(groupPanelId);
		if (!groupPanel) {
			groupPanel = $.CreatePanel("Panel", groupTable, groupPanelId);
			groupPanel.SetHasClass("cm_heroes_group", true);
		}

		_cm_Heroes_UpdateGroup(groupKV, groupPanel, groupName);
	}
}

function _cm_Heroes_UpdateGroup(groupKV, groupPanel, groupName) {
	var groupContainerId = "_heroes_group_container_" + groupName;
	var groupContainer = groupPanel.FindChild(groupContainerId);
	if (!groupContainer) {
		groupContainer = $.CreatePanel("Panel", groupPanel, groupContainerId);
		groupContainer.SetHasClass("cm_heroes_group_container", true);
		groupContainer.SetHasClass("hBlock", true);
	}

	for (var heroId in groupKV) {
		for (var name in groupKV[heroId]) {
			var heroPanelId = "_heroes_hero_" + name;
			var heroPanel = groupContainer.FindChild(heroPanelId);
			if (!heroPanel) {
				heroPanel = $.CreatePanel("Panel", groupContainer, heroPanelId);
				heroPanel.BLoadLayout(config.radiobutton, false, false);
				heroPanel.SetHasClass("cm_heroes_heropanel", true);
			}

			_cm_Heroes_UpdateHero(groupKV, heroPanel, groupName, heroId, name);
		}
	}
}

function _cm_Heroes_UpdateHero(groupKV, heroPanel, groupName, heroId, name) {
	var rButton = heroPanel.FindChildInLayoutFile("RadioButton");
	rButton.group = "Heroes";
	rButton.SetHasClass("hBlock", true);

	var isEnabled = groupKV[heroId][name];
	if (isEnabled == 0) {
		rButton.enabled = false;
	}

	rButton.data = {
		heroName: name,
		heroId: heroId,
		heroGroup: groupName
		// heroRow: row
	};

	var pID = Game.GetLocalPlayerInfo().player_id;     //玩家ID
	rButton.SetPanelEvent("onselect", PreviewHero(rButton));   //保存下选择的英雄内容
	var childImage = heroPanel.FindChildInLayoutFile("RadioImage");
	childImage.heroname = "npc_dota_hero_" + name;
}

function Hero_Ability_List_Update(heroName, playerId, isButtonEvent) {
	var container = $("#buyPanel")
	if (isButtonEvent) {
		ChangeToBuyPanel(false);
	}
	var parentPanelId = "_ability_list"
	var parentPanel = container.FindChild(parentPanelId);
	if (!parentPanel) {
		parentPanel = $.CreatePanel("Panel", container, parentPanelId);    //英雄技能的Panel
		parentPanel.BLoadLayout(config.heroAbilityList, false, false);     //英雄组的panel布局
		parentPanel.AddClass("player");
	}

	var childImage = parentPanel.FindChildInLayoutFile("HeroImage");
	var abilityList = parentPanel.FindChildInLayoutFile("Abilities");

	if (heroName != "") {
		childImage.heroname = "npc_dota_hero_" + heroName;            //英雄头像
		var slotNumber = 0;
		for (var abilitySlot in CustomNetTables.GetTableValue("abilities", heroName)) {
			slotNumber = slotNumber + 1;
		}
		if (!abilityList.maxslot || abilityList.maxslot < slotNumber) {
			abilityList.maxslot = slotNumber;
		}
		for (var slot = 1; slot <= abilityList.maxslot; slot++)                       //先全部隐藏起来
		{
			InvisibleAbilityList(abilityList, slot);
		}
		for (var slot = 1; slot <= slotNumber; slot++)                                //英雄技能列表
		{
			UpdateAbility(abilityList, heroName, slot, playerId);
		}
	}
}

function InvisibleAbilityList(abilityList, slot) {
	var abButtonId = "_ability_new_" + slot;
	var abButton = abilityList.FindChild(abButtonId);
	if (abButton) {
		abButton.SetHasClass("hidden", true);
	}
}

function UpdateAbility(abilityList, heroName, slot, playerId) {
	var abButtonId = "_ability_new_" + slot;
	var abButton = abilityList.FindChild(abButtonId);
	if (!abButton) {
		abButton = $.CreatePanel("Button", abilityList, abButtonId);
	}
	abButton.SetHasClass("hidden", false);

	var abPanelId = "_ability_image_" + slot;
	var abPanel = abButton.FindChild(abPanelId);
	var abCostLabelId = "_ability_cost_" + slot;
	var abCostLabel = abButton.FindChild(abCostLabelId);
	var abilityName = CustomNetTables.GetTableValue("abilities", heroName)[slot];
	if (!abPanel) {
		abPanel = $.CreatePanel("DOTAAbilityImage", abButton, abPanelId);
		abPanel.SetHasClass("hBlock", true);
		abPanel.SetHasClass("vBlock", true);
		var costInit = 1;
		abPanel.data = {
			abilityName: abPanel.abilityname,
			heroName: heroName,
			position: slot,
			playerId: playerId,
			abilityCost: 1,
			enough: false
		}

		abButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(abPanel));
		abButton.SetPanelEvent("onmouseout", HideAbilityTooltip(abPanel));
		abButton.SetPanelEvent("onactivate", AddAbility(abPanel));
		abCostLabel = $.CreatePanel("Label", abButton, abCostLabelId);
		ResetPanelData(abPanel, abCostLabel, abilityName, heroName, playerId);
	}
	else    //更新技能
	{
		ResetPanelData(abPanel, abCostLabel, abilityName, heroName, playerId);
	}
}

function ResetPanelData(abPanel, abCostLabel, abilityName, heroName, playerId) {
	abPanel.abilityname = abilityName;
	abPanel.data.abilityName = abilityName;
	abPanel.data.heroName = heroName;
	var abilityCost = GetAbilityCost(abilityName);
	abCostLabel.text = abilityCost;
	abPanel.data.abilityCost = abilityCost;
	if (!AbilityPointEnough(abilityCost, playerId))      //技能点不够
	{
		abPanel.data.enough = false;
		abPanel.SetHasClass("notEnoughDark", true);
	}
	else {
		abPanel.data.enough = true;
		abPanel.SetHasClass("notEnoughDark", false);
	}
	CheckAbilityButtonAvailable(abPanel.GetParent(), abilityName, playerId);
}

function GetAttributeBonusLevel(playerId) {
	var playerHeroIndex = Players.GetPlayerHeroEntityIndex(playerId);
	var abilityIndex = Entities.GetAbilityByName(playerHeroIndex, "attribute_bonus_lua")
	var level = Abilities.GetLevel(abilityIndex);
	if (level < 0) {
		level = 0;
	}
	return level;
}

function UpdateAttributeButtons() {
	var attrbutton = $("#attributeButton")
	var pointToGoldButton = $("#pointToGoldButton")

	var playerId = Game.GetLocalPlayerInfo().player_id;

	if (!AbilityPointEnough(1, playerId)) {
		attrbutton.SetHasClass("notEnoughDark", true);
		attrbutton.enough = 0;
		pointToGoldButton.SetHasClass("notEnoughDark", true);
		pointToGoldButton.enough = 0;
	}
	else {
		attrbutton.SetHasClass("notEnoughDark", false);
		attrbutton.enough = 1;
		pointToGoldButton.SetHasClass("notEnoughDark", false);
		pointToGoldButton.enough = 1;
	}

	attrbutton.GetChild(1).text = GetAttributeBonusLevel(playerId);  //设置黄点技能与卖黄点技能两个按钮状态
}

function UpdateCourierButtons() {

	var fortitudeButton = $("#FortitudeButton");
	var burstButton = $("#BurstButton");
	var shieldButton = $("#ShieldButton");
	var blinkButton = $("#BlinkButton");
	var hookButton = $("#HookButton");
	var sellItemsButton = $("#SellItemsButton");
	//var synButton = $("#SynButton");

	var playerId = Game.GetLocalPlayerInfo().player_id;

	if (!AbilityPointEnough(1, playerId))
	{
		fortitudeButton.SetHasClass("notEnoughDark", true);
		fortitudeButton.enough = 0;
		burstButton.SetHasClass("notEnoughDark", true);
		burstButton.enough = 0;
		shieldButton.SetHasClass("notEnoughDark", true);
		shieldButton.enough = 0;
		blinkButton.SetHasClass("notEnoughDark", true);
		blinkButton.enough = 0;
		hookButton.SetHasClass("notEnoughDark", true);
		hookButton.enough = 0;
		sellItemsButton.SetHasClass("notEnoughDark", true);
		sellItemsButton.enough = 0;
		//synButton.SetHasClass("notEnoughDark", true);
		//synButton.enough = 0;
	}
	else
	{
		fortitudeButton.SetHasClass("notEnoughDark", false);
		fortitudeButton.enough = 1;
		burstButton.SetHasClass("notEnoughDark", false);
		burstButton.enough = 1;
		shieldButton.SetHasClass("notEnoughDark", false);
		shieldButton.enough = 1;
		blinkButton.SetHasClass("notEnoughDark", false);
		blinkButton.enough = 1;
		hookButton.SetHasClass("notEnoughDark", false);
		hookButton.enough = 1;
		sellItemsButton.SetHasClass("notEnoughDark", false);
		sellItemsButton.enough = 1;
		//synButton.SetHasClass("notEnoughDark", false);
		//synButton.enough = 1;
	}
}

function GetAbilityCost(abilityName) {
	var abilityCost = 1;
	var abcost = CustomNetTables.GetTableValue("abilitiesCost", abilityName);
	if (abcost == null) {
		abilityCost = 1;
	}
	else {
		abilityCost = abcost[1];
	}
	return abilityCost;
}

function AbilityPointEnough(abilityCost, playerId) {
	var playerHeroIndex = Players.GetPlayerHeroEntityIndex(playerId);
	return abilityCost <= Entities.GetAbilityPoints(playerHeroIndex);
}

function CheckAbilityButtonAvailable(Button, abilityName, playerId) {
	var playerHeroIndex = Players.GetPlayerHeroEntityIndex(playerId);
	var abilityIndex = Entities.GetAbilityByName(playerHeroIndex, abilityName);
	if (abilityIndex == -1)  //找一下是否有光环类的升级技能
	{
		abilityIndex = Entities.GetAbilityByName(playerHeroIndex, abilityName + "_level_2");
	}
	if (abilityIndex == -1) {
		abilityIndex = Entities.GetAbilityByName(playerHeroIndex, abilityName + "_level_3");
	}
	if (!buySpellLocking)  //如果处于买技能的加锁期间，不解锁按钮
	{
		if (abilityIndex == -1) {
			Button.enabled = true;
		}
		else {
			Button.enabled = false;
		}
		if (GetPlayerAbilityNumber(playerId) >= maxAbilitySlotNo) {
			Button.enabled = false;
		}
	}
}

function InvisiblePlayerAbilityList(abilityList, slot) {
	var abButtonId = "player_ability_" + slot;
	var abButton = abilityList.FindChild(abButtonId);
	if (abButton) {
		abButton.SetHasClass("hidden", true);
		if (maxAbilitySlotNo == 7) {
			abButton.style.maxWidth = "75px"
		}
		if (maxAbilitySlotNo == 8) {
			abButton.style.maxWidth = "70px"
		}
		if (maxAbilitySlotNo == 9) {
			abButton.style.maxWidth = "65px"
		}
	}
}

//参数 playId 还有个参数是刚移除技能的名字，7.07的改动，使后台更新的技能列表  前台使用Entities.GetAbility不能立即生效
//需要从后台主动推送过来
function PlayerAbilityListUpdate(keys) {

	var playerId = keys.playerId;
	var deleteAbilityName = keys.deleteAbilityName;

	var container = $("#sellPanel");
	var parentPanelId = "player_ability_list";
	var parentPanel = container.FindChild(parentPanelId);
	if (!parentPanel) {
		parentPanel = $.CreatePanel("Panel", container, parentPanelId);    //英雄技能的Panel
		parentPanel.BLoadLayout(config.playerAbilityList, false, false);     //英雄组的panel布局
		parentPanel.AddClass("player");
		//container.SetHasClass("hidden", true);
	}

	var childImage = parentPanel.FindChildInLayoutFile("PlayerImage");
	var playerAbilityList = parentPanel.FindChildInLayoutFile("PlayerAbilities");
	var playerdata = Game.GetPlayerInfo(playerId);
	childImage.steamid = playerdata.player_steamid;                        //玩家的SteamId用来显示头像
	var playerHeroIndex = Players.GetPlayerHeroEntityIndex(playerId);
	var slotNumber = 0;
	if (playerAbilityList.maxslot >= 1) {
		for (var slot = 1; slot <= playerAbilityList.maxslot; slot++)             //先全部隐藏起来
		{
			InvisiblePlayerAbilityList(playerAbilityList, slot);
		}
	}
	for (var i = 0; i <= 20; i++) {
		var ability = Entities.GetAbility(playerHeroIndex, i);
		var abilityName = Abilities.GetAbilityName(ability);
		if (abilityName != "" && abilityName != deleteAbilityName && hideAbility[abilityName] != true && abilityName.substring(0, 14) != "special_bonus_") //天赋技能默认隐藏
		{
			slotNumber = slotNumber + 1;
			UpdatePlayerAbility(playerAbilityList, slotNumber, abilityName, playerId);
		}
	}
	if (!playerAbilityList.maxslot || playerAbilityList.maxslot < slotNumber) {
		playerAbilityList.maxslot = slotNumber;
	}
}

function GetPlayerAbilityNumber(playerId) {
	var abilityNumber = 0;
	var playerHeroIndex = Players.GetPlayerHeroEntityIndex(playerId);
	for (var i = 0; i <= 20; i++) {
		var abilityName = Abilities.GetAbilityName(Entities.GetAbility(playerHeroIndex, i));
		if (abilityName != "" && hideAbility[abilityName] != true && abilityName.substring(0, 14) != "special_bonus_") {
			abilityNumber = abilityNumber + 1;
		}
	}
	return abilityNumber;
}

function UpdatePlayerAbility(abilityList, slot, abilityName, playerId) {
	var abButtonId = "player_ability_" + slot;
	var abButton = abilityList.FindChild(abButtonId);
	if (!abButton) {
		abButton = $.CreatePanel("Button", abilityList, abButtonId);
	}
	abButton.SetHasClass("hidden", false);
	var abPanelId = "player_ability_image_" + slot;
	var abPanel = abButton.FindChild(abPanelId);
	var sellCostLabelId = "ability_sell_cost_" + slot;
	var sellCostLabel = abButton.FindChild(sellCostLabelId);
	if (!abPanel) {
		abPanel = $.CreatePanel("DOTAAbilityImage", abButton, abPanelId);
		abPanel.SetHasClass("hBlock", true);
		abPanel.SetHasClass("vBlock", true);
		abPanel.data = {
			abilityName: abilityName,
			playerId: playerId,
			abilityCost: 1,
			abilityLevel: 1,
		}
		abButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(abPanel));
		abButton.SetPanelEvent("onmouseout", HideAbilityTooltip(abPanel));
		abButton.SetPanelEvent("onactivate", RemoveAbility(abPanel));
		sellCostLabel = $.CreatePanel("Label", abButton, sellCostLabelId);
		ResetSellAbilityList(abilityName, sellCostLabel, abPanel, playerId);
	}
	else    //更新图片跟技能名字
	{
		ResetSellAbilityList(abilityName, sellCostLabel, abPanel, playerId);
		abPanel.abilityname = abilityName;
		abPanel.data.name = abPanel.abilityname;
	}
}

function ResetSellAbilityList(abilityName, sellCostLabel, abPanel, playerId) {
	abPanel.abilityname = abilityName;
	abPanel.data.abilityName = abPanel.abilityname;
	var playerHeroIndex = Players.GetPlayerHeroEntityIndex(playerId);
	var abilityIndex = Entities.GetAbilityByName(playerHeroIndex, abilityName);
	var abilityCost = GetAbilityCost(abilityName);
	var abilityLevel = Abilities.GetLevel(abilityIndex);

	if (noReturnAbility[abilityName] == true) {
		abilityLevel = 1
	}
	var pointsReturn = abilityCost + abilityLevel - 1;
	var sellCost = Players.GetLevel(playerId) * pointsReturn * 30;
	if (freeToSellAbility) {
		sellCostLabel.text = "0";
		sellCostLabel.SetHasClass("lableGreen", true);
		sellCostLabel.SetHasClass("lableYellow", false);
	}
	else {
		sellCostLabel.text = "-" + sellCost;
		sellCostLabel.SetHasClass("lableGreen", false);
		sellCostLabel.SetHasClass("lableYellow", true);
	}
	abPanel.data.abilityCost = abilityCost;
	var str = abilityName.substring(0, 4);  //专属技能与不能卖的技能
	if (str == "self" || unsellableAbility[abilityName] == true) {
		abPanel.GetParent().enabled = false;
		sellCostLabel.SetHasClass("hidden", true);
	}
	else {
		abPanel.GetParent().enabled = true;
		sellCostLabel.SetHasClass("hidden", false);
	}
	if (Players.GetGold(playerId) < sellCost && !freeToSellAbility) //卖技能不免费
	{
		abPanel.SetHasClass("notEnoughDark", true);
	}
	else {
		abPanel.SetHasClass("notEnoughDark", false);
	}
}

function ChangeToBuyPanel(isButtonEvent) {
	var buyPanel = $("#buyPanel")
	buyPanel.SetHasClass("hidden", false);
	var sellPanel = $("#sellPanel")
	sellPanel.SetHasClass("hidden", true);
	var attrPanel = $("#attrPanel")
	attrPanel.SetHasClass("hidden", true);
	var courierPanel = $("#courierPanel")
	courierPanel.SetHasClass("hidden", true);

	if (isButtonEvent) {
		Game.EmitSound("ui.switchview");
	}
}

function ChangeToSellPanel() {
	var buyPanel = $("#buyPanel")
	buyPanel.SetHasClass("hidden", true);
	var attrPanel = $("#attrPanel")
	attrPanel.SetHasClass("hidden", true);

	var sellPanel = $("#sellPanel")
	sellPanel.SetHasClass("hidden", false);
	var playerId = Game.GetLocalPlayerInfo().player_id;

	var keys = {};
	keys.playerId = playerId;

	PlayerAbilityListUpdate(keys);

	var courierPanel = $("#courierPanel")
	courierPanel.SetHasClass("hidden", true);

	Game.EmitSound("ui.switchview");
}

function ChangeToAttrPanel() {
	var buyPanel = $("#buyPanel")
	buyPanel.SetHasClass("hidden", true);
	var sellPanel = $("#sellPanel")
	sellPanel.SetHasClass("hidden", true);
	var attrPanel = $("#attrPanel")
	attrPanel.SetHasClass("hidden", false);
	var courierPanel = $("#courierPanel")
	courierPanel.SetHasClass("hidden", true);
	Game.EmitSound("ui.switchview");
	UpdateAttributeButtons()
}

function ChangeToCourierPanel() {
	var buyPanel = $("#buyPanel")
	buyPanel.SetHasClass("hidden", true);
	var sellPanel = $("#sellPanel")
	sellPanel.SetHasClass("hidden", true);
	var attrPanel = $("#attrPanel")
	attrPanel.SetHasClass("hidden", true);
	var attrPanel = $("#attrPanel")
	attrPanel.SetHasClass("hidden", true);
	var courierPanel = $("#courierPanel")
	courierPanel.SetHasClass("hidden", false);
	Game.EmitSound("ui.switchview");

	var playerId = Players.GetLocalPlayer();
	var steam_id = Game.GetPlayerInfo(playerId).player_steamid;
	var tables = CustomNetTables.GetTableValue("vipMap", "" + ConvertToSteamId32(steam_id));
	var vipLevel = tables ? tables.level : 0;
	if (vipLevel >= 1)  //vip等级大于1 可以选后面的技能
	{
		var shieldButton = $("#ShieldButton")
		shieldButton.enabled = true;
		var blinkButton = $("#BlinkButton")
		blinkButton.enabled = true;
		var hookButton = $("#HookButton")
		hookButton.enabled = true;
		var sellItemsButton = $("#SellItemsButton")
		sellItemsButton.enabled = true;
		//var synButton = $("#SynButton")
		//synButton.enabled = true;
	}
	UpdateCourierButtons();
}

function SetAllAbilityUnabled(abPanel) {
	for (var i = 1; i <= 7; i++) {
		var abButtonId = "_ability_new_" + i;
		var abButton = abPanel.GetParent().GetParent().FindChild(abButtonId);
		if (abButton) {
			abButton.enabled = false;
		}
	}
}

function SetAllAbilityEnabled(abPanel) {
	for (var i = 1; i <= 7; i++) {
		var abButtonId = "#_ability_new_" + i;
		var abButton = $(abButtonId)
		if (abButton) {
			abButton.enabled = true;
		}
	}
}

var PreviewHero = (function (rButton) {
	return function () {
		var heroInfo = rButton.data;
		var playerId = Game.GetLocalPlayerInfo().player_id;
		Update_Heroes_Table();
		Hero_Ability_List_Update(heroInfo.heroName, playerId, true);
		CurrentHero[playerId] = heroInfo.heroName;
		if (previousHeroRadio != null) {
			previousHeroRadio.checked = false; //取消上一次点选的英雄（此处因为radio group失效）
		}
		previousHeroRadio = rButton;       //重新记录
	}
});

var AddAbility = (function (abPanel) {
	//$.Msg(abPanel.data)
	return function () {
		if (abPanel.data.enough && !buySpellLocking) {
			abPanel.GetParent().enabled = false;
			//直接禁用所有 等待后台回传再解锁
			SetAllAbilityUnabled(abPanel);
			//加锁 禁止期间所有操作
			buySpellLocking = true;
			GameEvents.SendCustomGameEventToServer("AddAbility", abPanel.data);
		}
	}
});

var RemoveAbility = (function (abPanel) {
	return function () {
		GameEvents.SendCustomGameEventToServer("RemoveAbility", abPanel.data);
	}
});

function attributeButton() {
	var attrbutton = $("#attributeButton")
	var playerId = Game.GetLocalPlayerInfo().player_id;
	GameEvents.SendCustomGameEventToServer("LevelUpAttribute", { playerId: playerId, enough: attrbutton.enough });
	attrbutton.enough = 0; //发完以后立即锁死 等待LUA回传结果 再判断是否解锁
}

function pointToGoldButton() {
	var pointToGoldButton = $("#pointToGoldButton")
	var playerId = Game.GetLocalPlayerInfo().player_id;
	GameEvents.SendCustomGameEventToServer("PointToGold", { playerId: playerId, enough: pointToGoldButton.enough });
	pointToGoldButton.enough = 0;  //发完以后立即锁死 等待LUA回传结果 再判断是否解锁 
}

function grantCourierAbility(key)   //赋予英雄信使物品
{
	if (key == 1) {
		var fortitudeButton = $("#FortitudeButton")
		var playerId = Game.GetLocalPlayerInfo().player_id;
		GameEvents.SendCustomGameEventToServer("GrantCourierAbility", { playerId: playerId, item: "item_courier_fortitude", enough: fortitudeButton.enough });
		fortitudeButton.enough = 0;
	}
	if (key == 2) {
		var burstButton = $("#BurstButton")
		var playerId = Game.GetLocalPlayerInfo().player_id;
		GameEvents.SendCustomGameEventToServer("GrantCourierAbility", { playerId: playerId, item: "item_courier_burst", enough: burstButton.enough });
		burstButton.enough = 0;
	}
	if (key == 3) {
		var shieldButton = $("#ShieldButton")
		var playerId = Game.GetLocalPlayerInfo().player_id;
		GameEvents.SendCustomGameEventToServer("GrantCourierAbility", { playerId: playerId, item: "item_courier_shield", enough: shieldButton.enough });
		shieldButton.enough = 0;
	}
	if (key == 4) {
		var blinkButton = $("#BlinkButton")
		var playerId = Game.GetLocalPlayerInfo().player_id;
		GameEvents.SendCustomGameEventToServer("GrantCourierAbility", { playerId: playerId, item: "item_courier_blink", enough: blinkButton.enough });
		blinkButton.enough = 0;
	}
	if (key == 5) {
		var hookButton = $("#HookButton")
		var playerId = Game.GetLocalPlayerInfo().player_id;
		GameEvents.SendCustomGameEventToServer("GrantCourierAbility", { playerId: playerId, item: "item_courier_hook", enough: hookButton.enough });
		hookButton.enough = 0;
	}
	if (key == 6) {
		var sellItemsButton = $("#SellItemsButton")
		var playerId = Game.GetLocalPlayerInfo().player_id;
		GameEvents.SendCustomGameEventToServer("GrantCourierAbility", { playerId: playerId, item: "item_courier_sell_items", enough: sellItemsButton.enough });
		sellItemsButton.enough = 0;
	}
	/**
	if (key == 7) {
		var synButton = $("#SynButton")
		var playerId = Game.GetLocalPlayerInfo().player_id;
		GameEvents.SendCustomGameEventToServer("GrantCourierAbility", { playerId: playerId, item: "item_courier_syn", enough: synButton.enough });
		synButton.enough = 0;
	}
	**/
}

function UpdateAbilityList(keys) {
	var isButtonEvent = true;
	//解锁
	buySpellLocking = false;

	if (keys.heroName == false) {
		keys.heroName = CurrentHero[keys.playerId];
		isButtonEvent = false;
	}
	if (keys.maxSlotNumber != null && keys.maxSlotNumber > maxAbilitySlotNo) {
		maxAbilitySlotNo = keys.maxSlotNumber  //更新最大技能数目
	}

	if (GetPlayerAbilityNumber(keys.playerId) <= maxAbilitySlotNo) //如果技能数未到达最大限制
	{
		SetAllAbilityEnabled();
	}

	Hero_Ability_List_Update(keys.heroName, keys.playerId, isButtonEvent);
	UpdateAttributeButtons();
	UpdateCourierButtons();
}

function UpdatePlayerAbilityList(keys) {
	PlayerAbilityListUpdate(keys);    //技能更新完毕，Lua通知UI更新英雄技能列表
}

function UpdateFreeToSell(keys) {
	if (keys.free == true) {
		freeToSellAbility = true; //卖技能不要钱
	}
	if (keys.free == false) {
		freeToSellAbility = false; //卖技能要钱
	}
	PlayerAbilityListUpdate(keys);
}

function HideMainBlock() {
	var mainBlock = $("#mainShop");
	mainBlock.invisible = true;
	mainBlock.SetHasClass("Hidden", true);
}

function InitTooltips() {
	var attributeButton = $("#attributeButton")
	attributeButton.abilityname = "attribute_bonus_lua";
	attributeButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(attributeButton));
	attributeButton.SetPanelEvent("onmouseout", HideAbilityTooltip(attributeButton));
	var pointToGoldButton = $("#pointToGoldButton")
	pointToGoldButton.abilityname = "skill_point_for_gold_tooltip";
	pointToGoldButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(pointToGoldButton));
	pointToGoldButton.SetPanelEvent("onmouseout", HideAbilityTooltip(pointToGoldButton));

	var fortitudeButton = $("#FortitudeButton")
	fortitudeButton.abilityname = "courier_fortitude_datadriven";
	fortitudeButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(fortitudeButton));
	fortitudeButton.SetPanelEvent("onmouseout", HideAbilityTooltip(fortitudeButton));

	var burstButton = $("#BurstButton")
	burstButton.abilityname = "courier_burst";
	burstButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(burstButton));
	burstButton.SetPanelEvent("onmouseout", HideAbilityTooltip(burstButton));

	var shieldButton = $("#ShieldButton")
	shieldButton.abilityname = "courier_shield_tip";
	shieldButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(shieldButton));
	shieldButton.SetPanelEvent("onmouseout", HideAbilityTooltip(shieldButton));
	shieldButton.enabled = false;

	var blinkButton = $("#BlinkButton")
	blinkButton.abilityname = "courier_blink_datadriven";
	blinkButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(blinkButton));
	blinkButton.SetPanelEvent("onmouseout", HideAbilityTooltip(blinkButton));
	blinkButton.enabled = false;

	var hookButton = $("#HookButton")
	hookButton.abilityname = "courier_hook_datadriven";
	hookButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(hookButton));
	hookButton.SetPanelEvent("onmouseout", HideAbilityTooltip(hookButton));
	hookButton.enabled = false;

	var sellItemsButton = $("#SellItemsButton")
	sellItemsButton.abilityname = "courier_sell_items_datadriven";
	sellItemsButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(sellItemsButton));
	sellItemsButton.SetPanelEvent("onmouseout", HideAbilityTooltip(sellItemsButton));
	sellItemsButton.enabled = false;
    
    /**
	var synButton = $("#SynButton")
	synButton.abilityname = "courier_syn_datadriven";
	synButton.SetPanelEvent("onmouseover", ShowAbilityTooltip(synButton));
	synButton.SetPanelEvent("onmouseout", HideAbilityTooltip(synButton));
	synButton.enabled = false;
	**/
}

(function () {
	Update_Heroes_Table();
	HideMainBlock();
	GameEvents.Subscribe("UpdateAbilityList", UpdateAbilityList);
	GameEvents.Subscribe("UpdatePlayerAbilityList", UpdatePlayerAbilityList);
	GameEvents.Subscribe("UpdateFreeToSell", UpdateFreeToSell);
	InitTooltips();
})();