return {
	["ItemAdded"] = "",
	["IngredientAdded"] = "", -- You may want to disable this since it might have a lot of unnecessary requests

	-- Item Creator
	-- These contains little to no rawData since the request is too large to be allowed
	["ItemCreated"] = "",
	["ItemModified"] = "",
	["ItemDeleted"] = "",

	-- Ingredient Creator
	-- These contains little to no rawData since the request is too large to be allowed
	["IngredientCreated"] = "",
	["IngredientModified"] = "",
	["IngredientDeleted"] = "",

	-- These can be spammed quite a lot of you have a lot of players
	["ItemUseStart"] = "",
	["ItemUseStop"] = "",

	-- Interactions
	["ItemPlaced"] = "",
	["ItemPickup"] = "",
	["ItemTransfer"] = "",
	["ItemDiscarded"] = "",
}