"use strict";

var NewRankTitle = $.Localize("#new_rank_recorded")

function AnnounceNewRank(data) {
	var announceText = $("#NewRankAnnounceText");
	if (announceText) {
		announceText.SetHasClass("hidden", false);
		announceText.text = NewRankTitle + data.new_rank;
	}
}

(function () {
	GameEvents.Subscribe("AnnounceNewRank", AnnounceNewRank);
})();