"use strict";

function GetRandomInt( min, max )
{
	return Math.floor( Math.random() * ( max - min + 1 ) ) + min;
}

var ShowAbilityTooltip = ( function( ability )
{
	return function()
	{
		$.DispatchEvent( "DOTAShowAbilityTooltip", ability, ability.abilityname );
	}
});

var HideAbilityTooltip = ( function( ability )
{
	return function()
	{
		$.DispatchEvent( "DOTAHideAbilityTooltip", ability );
	}
});